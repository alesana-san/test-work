# Тестовое задание

## Описание

В схеме 3 таблицы:
- организации ([organization](#organization))
- отделы ([department](#department))
- сотрудники ([employee](#employee))

#### organization

| Название поля | Тип  | Ограничение | Описание                 |
|:--------------|:-----|:------------|:-------------------------|
| ORG_ID        | int  | PK          | ID компании              |
| ORG_PARENT_ID | int  | FK          | ID родительской компании |
| NAME          | text | not null    | Название компании        |

#### department

| Название поля | Тип  | Ограничение | Описание                               |
|:--------------|:-----|:------------|:---------------------------------------|
| DEP_ID        | int  | PK          | ID отдела                              |
| ORG_ID        | int  | FK          | ID компании, которой принадлежит отдел |
| NAME          | text | not null    | Название отдела                        |

#### employee

| Название поля | Тип  | Ограничение | Описание                                   |
|:--------------|:-----|:------------|:-------------------------------------------|
| EMP_ID        | int  | PK          | ID сотрудника                              |
| DEP_ID        | int  | FK          | ID отдела, которому принадлежит сотрудник  |
| ORG_ID        | int  | FK          | ID компании, которой принадлежит сотрудник |
| NAME          | text | not null    | Имя сотрудника                             |

### Ограничения

- Организация может иметь в подчинении дочерние организации (уровень
  вложенности не более 3 организаций)
- В главной (родительской) организации поле ORG_PARENT_ID не заполнено
  (null)
- Система может содержать несколько родительских организаций.
- Организация может иметь в своем составе один или несколько отделов, а
  также к организации может быть привязан один или несколько
  пользователей (без отдела)
- Один отдел может принадлежать только одной организации.
- Каждый отдел может включать в себя одного или нескольких сотрудников.
  Один сотрудник может работать только в одном отделе, либо напрямую
  относится только к одной организации.

### Задание

1. Необходимо реализовать вывод данных (ID объекта, ID родительского
   объекта, NAME) в иерархическом виде (отступы не обязательно, но
   порядок строк чтобы соответствовал зависимости объектов друг от
   друга, отсортированные по NAME, но для организаций предварительно
   должна быть сделана сортировка, согласно которой пользователи,
   привязанные напрямую идут первыми, а отделы после них):

`````
Пример порядка отображения по полю NAME:
Организация 1
     Организация 2
          Поджигаев Махмуд Иванович
           Отдел 1
                Антонов Антон Антонович
                Иванов Иван Иванович
           Отдел 2 
                Дмитриев Дмитрий Дмитриевич
                Петров Петр Петрович
Организация 3
     Отдел 3
           Сидоров Сидор Сидорович
           Дормидонтов Дормидонт Антонович
`````

2. Реализовать фильтрацию по значению поля NAME по построенной в п.1
   иерархии следующим образом:
   1. Если под условие попадает запись из таблицы организаций или
      отделов, то показывать всю ветку, которая включает в себя
      найденный объект (от родительской организации до сотрудников)
    `````
    Например, условие поиска «Отдел 2», то результат выборки должен содержать такой набор строк:
    Организация 1
         Организация 2
               Отдел 2 
                    Дмитриев Дмитрий Дмитриевич
                    Петров Петр Петрович
    `````

   2. Если под условие попадает запись из таблицы пользователей, то показывать иерархию только от родительской организации до этого пользователя
    `````
    Например, условие поиска «Антонович», то результат выборки должен содержать такой набор строк:
    Организация 1
         Организация 2
               Отдел 1
                    Антонов Антон Антонович
    Организация 3
         Отдел 3
               Дормидонтов Дормидонт Антонович
    `````
    `````
    Например, условие поиска «Иванович», то результат выборки должен содержать такой набор строк:
    Организация 1
         Организация 2
              Поджигаев Махмуд Иванович
               Отдел 1
                       Иванов Иван Иванович
    `````
3. Если в результате фильтрации не было найдено ни одной записи – возвращать пустой ответ

### Результат
В результате выполнения тестового задания должны получиться:
1)	DDL скрипты создания схемы/таблиц/связей
2)	DML с заполнение тестовыми данными
3)	Функция на PL/pgSQL, которая на вход будет принимать текстовый параметр, по значению которого необходимо будет проводить фильтрацию, а в ответе отдавать табличный набор с данными. Если параметр не передан – возвращать полный набор строк иерархии (согласно пункту 1 описания задачи)

## Решение

### Допущения
1. Так как не описано, как вести себя в случае, если у организации есть дочерние организация, пользователи и отделы, то считаем, что сначала пойдут пользователи, за ними организации, после чего - отделы.

### Файлы
1. `build_schema.sql` - создает схему и таблицы;
2. `fill_data.sql` - наполняет тестовыми данными;
4. `get_hier.sql` - основная функция для построения требуемого результата

### Применение
1. `select * from get_hier(null);` - построить полную иерархию по данным в таблицах;
2. `select * from get_hier('Антонович');` - вывести иерархию с фильтрацией
