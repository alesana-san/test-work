set search_path to 'test_work';
CREATE OR REPLACE FUNCTION build_org_branch(IN p_org_id organization.org_id%type,
                                            IN p_padding text default '',
                                            IN p_found boolean default true,
                                            IN p_search_phrase text default '')
    RETURNS table
            (
                object_id int,
                parent_id int,
                name      text
            )
AS
$$
DECLARE
    d                       record;
    x                       record;
    v                       record;
    y                       record;
    s                       record;
    l_atom_padding constant text    := '  ';
    l_new_padding           text    := p_padding || l_atom_padding;
    l_found                 boolean := p_found;
    l_org_returned          boolean := false;
    l_dep_returned          boolean;
    l_org_id                organization.org_id%type;
    l_org_parent_id         organization.org_parent_id%type;
    l_name                  organization.name%type;
BEGIN
    select z.org_id, z.org_parent_id, p_padding || z.name
    into l_org_id, l_org_parent_id, l_name
    from organization z
    where z.org_id = p_org_id;

    if l_found or not l_found and l_name like '%' || p_search_phrase || '%' then
        object_id := l_org_id;
        parent_id := l_org_parent_id;
        name := l_name;
        RETURN NEXT;
        l_org_returned := true;
        l_found := true;
    end if;

    /*
     Допущение:
        так как не описано, как вести себя в случае, если у организации есть дочерние организация, пользователи
        и отделы, то считаем, что сначала пойдут пользователи, за ними организации, после чего - отделы
     */
    for d in (select e.emp_id, e.org_id, e.name
              from employee e
              where e.org_id = p_org_id
                and (l_found or not l_found and e.name like '%' || p_search_phrase || '%')
              order by e.name)
        loop
            if not l_org_returned then
                object_id := l_org_id;
                parent_id := l_org_parent_id;
                name := l_name;
                RETURN NEXT;
                l_org_returned := true;
            end if;
            object_id := d.emp_id;
            parent_id := p_org_id;
            name := l_new_padding || d.name;
            RETURN NEXT;
        end loop;

    for v in (select e.org_id from organization e where e.org_parent_id = p_org_id order by e.name)
        loop
            for s in (select zz.object_id, zz.parent_id, zz.name
                      from build_org_branch(v.org_id, l_new_padding, l_found, p_search_phrase) zz)
                loop
                    if not l_org_returned then
                        object_id := l_org_id;
                        parent_id := l_org_parent_id;
                        name := l_name;
                        RETURN NEXT;
                        l_org_returned := true;
                    end if;
                    object_id := s.object_id;
                    parent_id := s.parent_id;
                    name := s.name;
                    RETURN NEXT;
                end loop;
        end loop;

    for y in (select w.dep_id, w.org_id, w.name
              from department w
              where w.org_id = p_org_id
              order by w.name)
        loop
            l_dep_returned := false;
            if l_found or not l_found and y.name like '%' || p_search_phrase || '%' then
                object_id := y.dep_id;
                parent_id := y.org_id;
                name := l_new_padding || y.name;
                RETURN NEXT;
                l_dep_returned := true;
                l_found := true;
            end if;

            for x in (select e.emp_id, e.dep_id, e.name
                      from employee e
                      where e.dep_id = y.dep_id
                        and (l_found or not l_found and e.name like '%' || p_search_phrase || '%')
                      order by e.name)
                loop
                    if not l_org_returned then
                        object_id := l_org_id;
                        parent_id := l_org_parent_id;
                        name := l_name;
                        RETURN NEXT;
                        l_org_returned := true;
                    end if;
                    if not l_dep_returned then
                        object_id := y.dep_id;
                        parent_id := p_org_id;
                        name := l_new_padding || y.name;
                        RETURN NEXT;
                        l_dep_returned := true;
                    end if;
                    object_id := x.emp_id;
                    parent_id := y.dep_id;
                    name := l_new_padding || l_atom_padding || x.name;
                    RETURN NEXT;
                end loop;
        end loop;
end;
$$
    LANGUAGE PLPGSQL;