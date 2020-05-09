set search_path to 'test_work';
CREATE OR REPLACE FUNCTION get_hier(
    IN p_search_phrase text
)
    RETURNS table
            (
                object_id int,
                parent_id int,
                name      text
            )
AS
$$
BEGIN
    return query with recursive
                     params as (
                         select p_search_phrase search_phrase,
                                'B'             org_type, -- буквы нужны, чтобы задать далее сортировку
                                'C'             dep_type, -- сначала сотрудники, потом организации, за ними отделы
                                'A'             emp_type, -- в итоге получается составной идентификатор типа C0002, D0003, O0012
                                '00000000009'   cast_format -- формат нужен для того, чтобы C2 шел раньше C12, например
                     ),
                      -- собираем все сущности в одну кучу, чтобы собрать одну иерархию
                     all_objects as (
                         select e.org_id                                                       object_id,
                                params.org_type                                                object_type,
                                e.org_parent_id                                                parent_id,
                                case when e.org_parent_id is not null then params.org_type end parent_type,
                                e.name
                         from organization e,
                              params
                         union all
                         select e.dep_id        object_id,
                                params.dep_type object_type,
                                e.org_id        parent_id,
                                params.org_type parent_type,
                                e.name
                         from department e,
                              params
                         union all
                         select e.emp_id                                                                     object_id
                              , params.emp_type                                                              object_type
                              , case when e.org_id is not null then e.org_id else e.dep_id end               parent_id
                              , case when e.org_id is not null then params.org_type else params.dep_type end parent_type
                              , e.name
                         from employee e,
                              params
                     ),
                      -- собираем иерархию, сразу помечая подходящие узлы для поиска
                      -- с помощью padding делаем отступы на нижних уровнях иерархии
                      -- NB: нет проверок на циклы, т.к. циклов здесь быть не может,
                      -- ведь мы стартуем с организаций, у которых родитель пустой
                     hier as (
                         select a.*,
                                array [a.object_type || to_char(a.object_id, params.cast_format)]          hier_branch,
                                ''                                                                         padding,
                                case when a.name like '%' || params.search_phrase || '%' then 1 else 0 end likeness
                         from all_objects a,
                              params
                         where a.parent_type is null
                           and a.parent_id is null
                         union
                         select child.*,
                                parent.hier_branch ||
                                (child.object_type || to_char(child.object_id, params.cast_format))            hier_branch,
                                parent.padding || '  '                                                         padding,
                                case when child.name like '%' || params.search_phrase || '%' then 1 else 0 end likeness
                         from all_objects child
                                  join hier parent
                                       on parent.object_id = child.parent_id and parent.object_type = child.parent_type
                                  join params on 1 = 1
                     ),
                      -- собираем отмеченные узлы для поиска
                     likes as (
                         select h.object_id, h.object_type, h.hier_branch
                         from hier h
                         where h.likeness = 1
                     ),
                      -- для сбора веток пользуемся правилом:
                      -- текущий ID элемента входит в искомую ветку
                      -- либо ID какого-либо искомого узла входит в текущую ветку
                     filtered_hier as (
                         select *
                         from hier h
                         where exists(select 1
                                      from likes l,
                                           params
                                      where (h.object_type || to_char(h.object_id, params.cast_format)) = ANY
                                            (l.hier_branch)
                                         or (l.object_type || to_char(l.object_id, params.cast_format)) = ANY
                                            (h.hier_branch)
                                   )
                     )
                 select h.object_id, h.parent_id, h.padding || h.name padded_name
                 from filtered_hier h
                 order by h.hier_branch;
end;
$$
    LANGUAGE PLPGSQL;