-----------------
-- Organization
-----------------
create table if not exists organization
(
    org_id        integer not null
        constraint organization_pk
            primary key,
    org_parent_id integer
        constraint organization_fk
            references organization
            on delete cascade,
    name          text    not null
);

comment on table organization is 'Organization entity';

-----------------
-- Department
-----------------
create table if not exists department
(
    dep_id integer not null
        constraint department_pk
            primary key,
    org_id integer
        constraint dep_org_fk
            references organization
            on delete cascade,
    name   text    not null
);

comment on table department is 'Department entity';

-----------------
-- Employee
-----------------
create table if not exists employee
(
    emp_id integer not null
        constraint employee_pk
            primary key,
    dep_id integer
        constraint emp_dep_fk
            references department
            on delete cascade,
    org_id integer
        constraint emp_org_fk
            references organization
            on delete cascade,
    name   text    not null
);

comment on table employee is 'Employee entity';