-- сумма просмотров всех объявлений компании по продаже и аренде
SELECT t1.ID_user, t1.Name, t6.`tarif_name`, t3.trade, t4.rent, t5.parts FROM `tb_companies` AS t1 
INNER JOIN `tb_users` AS t2 ON (t1.`ID_user`=t2.`id`)
LEFT JOIN (SELECT id_user, COUNT(*) AS trade FROM `tb_stat_lots_true` WHERE `type` = '1' AND `date` >'2019-04-01 00:00:00' AND `date` < '2019-07-01' GROUP BY id_user ) AS t3  ON (t1.ID_user = t3.id_user)
LEFT JOIN (SELECT id_user, COUNT(*) AS rent FROM `tb_stat_lots_true` WHERE `type` = '2' AND `date` >'2019-04-01 00:00:00' AND `date` < '2019-07-01' GROUP BY id_user ) AS t4  ON (t1.ID_user = t4.id_user)
LEFT JOIN (SELECT id_user, COUNT(*) AS parts FROM `tb_stat_lots_true` WHERE `type` = '3' AND `date` >'2019-04-01 00:00:00' AND `date` < '2019-07-01' GROUP BY id_user ) AS t5  ON (t1.ID_user = t5.id_user)
INNER JOIN `tb_users_roles` AS t6 ON t2.`role_id`= t6.`id`
WHERE role_id IN (4,8,7,11)

-- сумма просмотров контактов всех объявлений компании по продаже
SELECT t1.Name, n1.trade_lot, n2.rent_lot, n3.part_lot
FROM `tb_companies` AS t1 
INNER JOIN `tb_users` AS t2 ON (t1.`ID_user`=t2.`id`)
LEFT JOIN (SELECT id_user, COUNT(*) AS trade_lot FROM `tb_stat_call_request_true` WHERE `type` = 'contact_trade_lot' AND `date` >'2019-03-01 00:00:00' AND `date` < '2019-04-01' GROUP BY id_user ) AS n1  ON (t1.ID_user = n1.id_user)
LEFT JOIN (SELECT id_user, COUNT(*) AS rent_lot FROM `tb_stat_call_request_true` WHERE `type` = 'contact_rent_lot' AND `date` >'2019-03-01 00:00:00' AND `date` < '2019-04-01' GROUP BY id_user ) AS n2  ON (t1.ID_user = n2.id_user)
LEFT JOIN (SELECT id_user, COUNT(*) AS part_lot FROM `tb_stat_call_request_true` WHERE `type` = 'contact_part' AND `date` >'2019-03-01 00:00:00' AND `date` < '2019-04-01' GROUP BY id_user ) AS n3  ON (t1.ID_user = n3.id_user)
WHERE role_id IN (4,8,7,11)

-- статистика просмотров по конкретному объявлению
SELECT t1.id_lot, COUNT(*), CONCAT("https://exkavator.ru/trade/lot/", t1.id_lot)FROM tb_stat_lots AS t1 
INNER JOIN tb_lots AS t2 
ON (t1.id_lot = t2.ID) 
WHERE t1.date >'2019-01-01 00:00:00' AND t1.date < '2019-03-31 23:59:59' AND t1.type !=3 AND t1.id_user = '29128' GROUP BY t1.id_lot

-- колво платников с определенным сроком действия тарифа
SELECT t3.tarif_name,t2.to FROM tb_users AS t1 
INNER JOIN tb_users_roles_history AS t2 ON (t1.id_role_history = t2.id_role_history) 
INNER JOIN tb_users_roles AS t3 ON (t1.role_id = t3.id) WHERE `to` > '2019-05-01 00:00:00' AND `to` < '2019-09-01 00:00:00' GROUP BY `to`

-- колво платников с определенным колвом объяв
SELECT id, username, (CountLots + CountRents + CountParts) AS cnt FROM tb_users WHERE role_id = '11' HAVING cnt > 114

-- Самые популярные модели (не по количеству просмотров а по подсчету объяв)
SELECT CatName,VehicleName, COUNT(*) AS cnt FROM tb_lots WHERE CatName = 'Колесные экскаваторы' AND Visible = 1 AND isLocked = 0 AND VehicleName IS NOT NULL GROUP BY VehicleName ORDER BY cnt DESC LIMIT 3

-- все производители с типами техники и странами        
SELECT country.Name, types.Name, prod.ID, prod.Title, prod.ShortTitle, t1.Name FROM _ccatalogue_producers AS prod 
        LEFT JOIN _ccatalogue_countries AS country ON country.ID=prod.Country
         INNER JOIN _ccatalogue_pv AS tech ON prod.id = tech.Producer
         INNER JOIN _ccatalogue AS catalog ON tech.Vehicle=catalog.ID
         INNER JOIN _ccatalogue_types AS `types` ON catalog.Type_ID =types.ID
         INNER JOIN _ccatalogue AS t1 ON tech.Vehicle = t1.ID
        ORDER BY prod.ShortTitle ASC

-- Мега выборка для совпадений по ЭРУ и ГРУ
SELECT tb_companies.ID AS 'ID ERU', tb_companies.Name AS 'name ERU', TitleURL, tb_regions_cities.name AS 'city ERU', tb_users.email AS 'email ERU', tb_companies.Phone AS 'phone ERU', 
tb_users.CountLots AS 'продажи', tb_users.CountRents AS 'аренды', tb_users.CountParts AS 'запчасти' FROM tb_companies
JOIN tb_regions_cities ON (tb_companies.ID_city = tb_regions_cities.city_id)
JOIN tb_users ON (tb_companies.ID_user = tb_users.id)  

-- вывод типа техники и ее родительской категории
SELECT t2.ID,t1.TitleURL,t2.TitleURL FROM tb_lots_cats AS t1 INNER JOIN tb_lots_cats AS t2 ON (t1.ID = t2.PID)
-- вывод типа техники и ее родительской категории полная версия
SELECT COUNT(tb_lots.ID) AS `Count`, CatURL, ProducerURL, VehicleURL, DateUpdate ,`justID`, `firstTitleURL`, `secondTitleURL`
FROM `tb_lots` 
JOIN (SELECT t2.ID AS `justID`, t1.TitleURL AS `firstTitleURL`, t2.TitleURL AS `secondTitleURL` FROM tb_lots_cats AS t1 INNER JOIN tb_lots_cats AS t2 ON (t1.ID = t2.PID)) AS t3 ON (tb_lots.`ID_cat` = `justID`)
WHERE TradeFlag = 1 AND VehicleURL IS NOT NULL AND VehicleURL != '' AND Visible = 1 AND isLocked = 0 AND isDeleted = 0 GROUP BY VehicleURL ORDER BY `Count` DESC

SELECT t4.Name,t3.cnt AS START,t5.cnt AS Base,t6.cnt AS Bussiness,t7.cnt AS BussinesPluss,t8.cnt AS Ultra,t9.cnt AS UltraPlus FROM tb_lots_cats AS t4 
LEFT JOIN (SELECT t1.ID_cat,t1.CatName,COUNT(*) AS cnt FROM tb_lots AS t1 INNER JOIN tb_users AS t2 ON (t1.ID_user = t2.id) WHERE t2.role_id = 1 AND t1.Visible=1 GROUP BY ID_cat) AS t3 ON (t4.ID = t3.ID_cat)
LEFT JOIN (SELECT t1.ID_cat,t1.CatName,COUNT(*) AS cnt FROM tb_lots AS t1 INNER JOIN tb_users AS t2 ON (t1.ID_user = t2.id) WHERE t2.role_id = 3 AND t1.Visible=1 GROUP BY ID_cat) AS t5 ON (t4.ID = t5.ID_cat)
LEFT JOIN (SELECT t1.ID_cat,t1.CatName,COUNT(*) AS cnt FROM tb_lots AS t1 INNER JOIN tb_users AS t2 ON (t1.ID_user = t2.id) WHERE t2.role_id = 4 AND t1.Visible=1 GROUP BY ID_cat) AS t6 ON (t4.ID = t6.ID_cat)
LEFT JOIN (SELECT t1.ID_cat,t1.CatName,COUNT(*) AS cnt FROM tb_lots AS t1 INNER JOIN tb_users AS t2 ON (t1.ID_user = t2.id) WHERE t2.role_id = 8 AND t1.Visible=1 GROUP BY ID_cat) AS t7 ON (t4.ID = t7.ID_cat)
LEFT JOIN (SELECT t1.ID_cat,t1.CatName,COUNT(*) AS cnt FROM tb_lots AS t1 INNER JOIN tb_users AS t2 ON (t1.ID_user = t2.id) WHERE t2.role_id = 7 AND t1.Visible=1 GROUP BY ID_cat) AS t8 ON (t4.ID = t8.ID_cat)
LEFT JOIN (SELECT t1.ID_cat,t1.CatName,COUNT(*) AS cnt FROM tb_lots AS t1 INNER JOIN tb_users AS t2 ON (t1.ID_user = t2.id) WHERE t2.role_id = 11 AND t1.Visible=1 GROUP BY ID_cat) AS t9 ON (t4.ID = t9.ID_cat)
WHERE t4.PID>0 ORDER BY t4.Name

-- стата на месяц по просмотру контактов
SELECT `Name` AS 'Название компании',CONCAT('https://exkavator.ru/trade/admin/companymanager/show_register_data/user_id/', tb_users.id) AS 'ссылка на аккаунт', 
Phone AS 'Телефон', role_id AS 'тариф', (CountLots + CountRents + CountParts) AS 'количество объявлений',last_login AS 'Послед. логирование', last_ip, created,  
COUNT(tb_stat_call_request.date) AS 'просмотр контакта'
 FROM tb_users JOIN `tb_stat_call_request` ON (tb_users.id = tb_stat_call_request.ID_user)
 JOIN tb_companies ON (tb_users.id = tb_companies.id_user) 
 WHERE created > '2018-01-01 00:00:00' 
 AND tb_stat_call_request.type IN ('contact_part', 'contact_rent_lot', 'contact_trade_lot') 
 AND tb_stat_call_request.date > '2019-06-01' AND tb_stat_call_request.date < '2019-07-01'
 GROUP BY tb_users.id

-- стата на месяц по обратным звонкам
SELECT `Name` AS 'Название компании',CONCAT('https://exkavator.ru/trade/admin/companymanager/show_register_data/user_id/', tb_users.id) AS 'ссылка на аккаунт', 
Phone AS 'Телефон', role_id AS 'тариф', (CountLots + CountRents + CountParts) AS 'количество объявлений',last_login AS 'Послед. логирование', last_ip, created,  
COUNT(tb_stat_call_request_true.date) AS 'Нажатие Обратного звонка'
 FROM tb_users JOIN `tb_stat_call_request_true` ON (tb_users.id = tb_stat_call_request_true.id_user)
 JOIN tb_companies ON (tb_users.id = tb_companies.id_user) 
 WHERE created > '2018-01-01 00:00:00' 
 AND tb_stat_call_request_true.type IN ('call_part', 'call_rent', 'call_trade') 
 AND tb_stat_call_request_true.date > '2019-06-01' AND tb_stat_call_request_true.date < '2019-07-01'
 GROUP BY tb_users.id

--  стата на месяц по обращению по email из лота
SELECT `Name` AS 'Название компании',CONCAT('https://exkavator.ru/trade/admin/companymanager/show_register_data/user_id/', tb_users.id) AS 'ссылка на аккаунт', 
Phone AS 'Телефон', role_id AS 'тариф', (CountLots + CountRents + CountParts) AS 'количество объявлений',last_login AS 'Послед. логирование', last_ip, created,  
COUNT(tb_stat_messages_to_trader.date) AS 'обращение по email из лота'
 FROM tb_users JOIN `tb_stat_messages_to_trader` ON (tb_users.id = tb_stat_messages_to_trader.id_user)
 JOIN tb_companies ON (tb_users.id = tb_companies.id_user) 
 WHERE created > '2018-01-01 00:00:00' 
 AND tb_stat_messages_to_trader.type IN ('message_part', 'message_rent', 'message_trade') 
 AND tb_stat_messages_to_trader.date > '2019-06-01' AND tb_stat_messages_to_trader.date < '2019-07-01'
 GROUP BY tb_users.id
 
-- для какого нибудь одного лота 
-- просмотр контактов на каждый день
 SELECT COUNT(*) FROM  tb_stat_call_request WHERE tb_stat_call_request.id_lot = '547480' AND 
tb_stat_call_request.date = '2019-08-01'
-- просмотр объявы на каждый день 
SELECT COUNT(*) FROM  tb_stat_lots WHERE tb_stat_lots.id_lot = '547480' AND tb_stat_lots.date = '2019-08-01'

-- по колву объяв
SELECT  `Name` AS 'Компания',role_id AS 'тариф' , (CountLots + CountRents + CountParts) AS 'кол-во объяв'
FROM tb_users 
JOIN `tb_companies` ON (tb_users.id = tb_companies.ID_user)
WHERE role_id IN (4,7,8,11) AND Visible = 1

количество объявлений платников по городам
SELECT t1.CityName,t1.ID_city,COUNT(*) AS 'Общее количество лотов',t3.tarif AS 'Бизнес',t4.tarif AS 'Бизнес+', t5.tarif AS 'Ультра', t6.tarif AS 'Ультра+', t7.tarif AS 'базовый', t8.tarif AS 'базовый'
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city,COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 4
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t3 ON (t1.ID_city = t3.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 8
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t4 ON (t1.ID_city = t4.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 7
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t5 ON (t1.ID_city = t5.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 11
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t6 ON (t1.ID_city = t6.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 1
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t7 ON (t1.ID_city = t7.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 3
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t8 ON (t1.ID_city = t8.ID_city)

WHERE t2.Visible = 1  
GROUP BY t1.ID_city ORDER BY t1.CityName

первый столбец — город
второй столбец — количество объявлений платников по этому городу (по типу техники)
третий столбец — количество объявлений бесплатников по этому городу (по типу техники)
По итогу получится документ с 100+ листами в экселе (или 100+ документов) по каждому из типов техники в городе

SELECT t1.CityName,t1.ID_city, t3.tarif AS 'Бизнес',t4.tarif AS 'Бизнес+', t5.tarif AS 'Ультра', t6.tarif AS 'Ультра+', t7.tarif AS 'базовый', t8.tarif AS 'базовый'
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city,COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 4 AND t2.ID_cat = 17
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t3 ON (t1.ID_city = t3.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 8 AND t2.ID_cat = 17
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t4 ON (t1.ID_city = t4.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 7 AND t2.ID_cat = 17
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t5 ON (t1.ID_city = t5.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 11 AND t2.ID_cat = 17
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t6 ON (t1.ID_city = t6.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 1 AND t2.ID_cat = 17
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t7 ON (t1.ID_city = t7.ID_city)

LEFT JOIN 
(SELECT t1.ID_city AS ID_city, COUNT(*) AS tarif
FROM tb_lots_to_city AS t1 
INNER JOIN tb_lots AS t2 ON (t1.ID_lot = t2.ID) 
INNER JOIN tb_users AS t3 ON (t2.ID_user = t3.id) 
WHERE t2.Visible = 1  AND t3.role_id = 3 AND t2.ID_cat = 17
GROUP BY t1.ID_city ORDER BY t1.CityName) AS t8 ON (t1.ID_city = t8.ID_city)
GROUP BY t1.ID_city ORDER BY t1.CityName

-- просм объяв
SELECT t1.ID_user, t1.Name,  t3.trade, t4.rent, t5.parts FROM `tb_companies` AS t1 
INNER JOIN `tb_users` AS t2 ON (t1.`ID_user`=t2.`id`)
LEFT JOIN (SELECT id_user, COUNT(*) AS trade FROM `tb_stat_lots_true` WHERE `type` = '1' AND `date` >'2019-02-18 00:00:00'  GROUP BY id_user ) AS t3  ON (t1.ID_user = t3.id_user)
LEFT JOIN (SELECT id_user, COUNT(*) AS rent FROM `tb_stat_lots_true` WHERE `type` = '2' AND `date` >'2019-02-18 00:00:00'  GROUP BY id_user ) AS t4  ON (t1.ID_user = t4.id_user)
LEFT JOIN (SELECT id_user, COUNT(*) AS parts FROM `tb_stat_lots_true` WHERE `type` = '3' AND `date` >'2019-02-18 00:00:00'  GROUP BY id_user ) AS t5  ON (t1.ID_user = t5.id_user)
WHERE t1.`ID_user` = 54470

-- просм контактов
SELECT t1.Name, n1.trade_lot, n2.rent_lot, n3.part_lot
FROM `tb_companies` AS t1 
INNER JOIN `tb_users` AS t2 ON (t1.`ID_user`=t2.`id`)
LEFT JOIN (SELECT id_user, COUNT(*) AS trade_lot FROM `tb_stat_call_request` WHERE `type` = 'contact_trade_lot' AND `date` >'2019-02-18 00:00:00' GROUP BY id_user ) AS n1  ON (t1.ID_user = n1.id_user)
LEFT JOIN (SELECT id_user, COUNT(*) AS rent_lot FROM `tb_stat_call_request` WHERE `type` = 'contact_rent_lot' AND `date` >'2019-02-18 00:00:00' GROUP BY id_user ) AS n2  ON (t1.ID_user = n2.id_user)
LEFT JOIN (SELECT id_user, COUNT(*) AS part_lot FROM `tb_stat_call_request` WHERE `type` = 'contact_part' AND `date` >'2019-02-18 00:00:00' GROUP BY id_user ) AS n3  ON (t1.ID_user = n3.id_user)
WHERE t1.`ID_user` = 54470

-- нажатие обратного звонка
SELECT id_user, COUNT(tb_stat_call_request_true.date) AS 'Нажатие Обратного звонка'
 FROM tb_stat_call_request_true
 WHERE tb_stat_call_request_true.type IN ('call_part', 'call_rent', 'call_trade') 
 AND tb_stat_call_request_true.date > '2019-02-18' AND id_user = 54470 

-- обр по емайл из лота
SELECT COUNT(tb_stat_messages_to_trader.date) AS 'обращение по email из лота'
 FROM tb_users JOIN `tb_stat_messages_to_trader` ON (tb_users.id = tb_stat_messages_to_trader.id_user)
 AND tb_stat_messages_to_trader.type IN ('message_part', 'message_rent', 'message_trade') 
 AND tb_stat_messages_to_trader.date > '2019-02-18' AND id_user = 54470

-- просмотр контактов для каждой объявы за месяц
SELECT CompanyName, CONCAT('https://exkavator.ru/trade/lot/',id_lot) AS 'ID объявы',COUNT(tb_stat_call_request_true.date) AS 'просмотр контакта' FROM tb_lots 
JOIN tb_stat_call_request_true ON (tb_lots.ID = tb_stat_call_request_true.id_lot)
WHERE ID_company = 16417 
AND tb_stat_call_request_true.type IN ('contact_rent_lot', 'contact_trade_lot')
AND tb_stat_call_request_true.date > '2019-08-01' AND tb_stat_call_request_true.date < '2019-08-22'
GROUP BY id_lot

-- Кол-во использованных поднятий объявлений за июнь с разбивкой по дням
SELECT * FROM `tb_stat_uprate` WHERE ID_user = 48989 AND `Date` > '2019-07-01' AND `Date` < '2019-08-01'

-- для компании просмотры по дням
SELECT id_lot,`date`, COUNT(`date`) FROM `tb_stat_lots_true`
WHERE id_user = '27213' AND `time` > '2019-07-01' AND `time` < '2019-08-26'
GROUP BY `date`

-- для компании нажатия звонка по дням
SELECT id_user, `date`, COUNT(tb_stat_call_request_true.date) AS 'Нажатие Обратного звонка'
 FROM tb_stat_call_request_true
 WHERE tb_stat_call_request_true.type IN ('call_part', 'call_rent', 'call_trade') 
 AND tb_stat_call_request_true.date > '2019-07-01' AND tb_stat_call_request_true.date < '2019-08-26' AND id_user = 21415 GROUP BY `date`

-- Экскаваторы Москва Купить просмотр объяв за месяц (данные для аналитики)
SELECT tb_lots.ID, CatName, CityName,tb_stat_lots_true.date, Views FROM tb_lots 
JOIN tb_stat_lots_true ON (tb_lots.ID = tb_stat_lots_true.id_lot) 
WHERE tb_stat_lots_true.type = 1 AND CityName = 'Москва' AND 
tb_stat_lots_true.date > '2019-07-26' AND tb_stat_lots_true.date < '2019-08-27' AND
(CatName = 'Гусеничные экскаваторы' OR CatName = 'Фронтальные погрузчики (колесные)') AND Visible = 1

-- компании просмотр объяв помесячно, Дефолтный запрос
SELECT CONCAT('https://exkavator.ru/trade/lot/',id_lot) AS 'lot', COUNT(`date`) AS 'views' FROM tb_stat_lots WHERE id_user = '62648' AND `date` > '2020-02-01' AND `date` < '2020-02-07' GROUP BY id_lot