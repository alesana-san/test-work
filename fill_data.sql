set search_path to 'test_work';
insert into organization(org_id, org_parent_id, name) values(1, null, 'Организация 1');
insert into organization(org_id, org_parent_id, name) values(2, 1, 'Организация 2');
insert into organization(org_id, org_parent_id, name) values(3, null, 'Организация 3');

insert into department(dep_id, org_id, name) values(1, 2, 'Отдел 1');
insert into department(dep_id, org_id, name) values(2, 2, 'Отдел 2');
insert into department(dep_id, org_id, name) values(3, 3, 'Отдел 3');

insert into employee(emp_id, dep_id, org_id, name) values(1, null, 2, 'Поджигаев Махмуд Иванович');
insert into employee(emp_id, dep_id, org_id, name) values(2, 1, null, 'Антонов Антон Антонович');
insert into employee(emp_id, dep_id, org_id, name) values(3, 1, null, 'Иванов Иван Иванович');
insert into employee(emp_id, dep_id, org_id, name) values(4, 2, null, 'Дмитриев Дмитрий Дмитриевич');
insert into employee(emp_id, dep_id, org_id, name) values(5, 2, null, 'Петров Петр Петрович');
insert into employee(emp_id, dep_id, org_id, name) values(6, 3, null, 'Сидоров Сидор Сидорович');
insert into employee(emp_id, dep_id, org_id, name) values(7, 3, null, 'Дормидонтов Дормидонт Антонович');
commit;