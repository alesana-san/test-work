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
DECLARE
    c record;
BEGIN
    for c in (select e.org_id from organization e where e.org_parent_id is null order by e.name)
        loop
            return query select *
                         from build_org_branch(c.org_id, '', case when p_search_phrase is null then true else false end,
                                               p_search_phrase);
        end loop;

end;
$$
    LANGUAGE PLPGSQL;