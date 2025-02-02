/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: 
 * Дата: 
*/

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков


-- 1.1. Доля платящих пользователей по всем данным:
-- Напишите ваш запрос здесь
--	WITH all_data AS (									--CTE Подзапрос для подсчёта общего количества пользователей в таблице users  
--    SELECT (SELECT COUNT(*) AS all_users_count			
--			FROM fantasy.users) AS
--			all_users_count,
--        COUNT(payer) AS all_payers_count        -- Подсчёт количества платящие пользователей
--    FROM fantasy.users u
--    WHERE payer = 1
--)
--SELECT all_users_count,
--		all_payers_count,
--		ROUND(all_payers_count/all_users_count::NUMERIC, 4) AS payers_perc
--FROM all_data;

SELECT
	COUNT(payer) AS all_users_count, 
	SUM(payer) AS all_payers_count, 
	ROUND(AVG(payer),4) AS  payers_perc
FROM fantasy.users
									-- all_users_count  all_payers_count      payers_perc
									--		22214	         3929	             0.1769




-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
-- Напишите ваш запрос здесь
--WITH reg_payer AS( 				
--	SELECT race_id,
--		   race,								-- названия рассы
--		   COUNT(payer) AS all_payers_count		  --подсчёта общего количества платяших пользователей
--		FROM fantasy.users u 
--		LEFT JOIN fantasy.race r2 USING(race_id)
--WHERE registration_dt IS NOT NULL AND payer = 1
--GROUP BY race_id,race
--)
--SELECT 
--	r.race,
--	r.all_payers_count,		 
--	COUNT(*) AS registred_users,		--подсчёта общего количества пользователей
--	ROUND(r.all_payers_count :: NUMERIC / COUNT(*), 4) AS race_payers_share --платящих игроков от общего количества пользователей, зарегистрированных в игре в разрезе каждой расы персонажа
--FROM fantasy.users u 
--LEFT JOIN reg_payer r USING(race_id)
--GROUP BY race, all_payers_count
--ORDER BY race;

SELECT 
	r.race,
	SUM(payer) AS all_payers_count,		 
	COUNT(*) AS registred_users,		--подсчёта общего количества пользователей
	ROUND(AVG(payer) :: NUMERIC, 4) AS race_payers_share --платящих игроков от общего количества пользователей, зарегистрированных в игре в разрезе каждой расы персонажа
FROM fantasy.users u 
LEFT JOIN fantasy.race r USING(race_id)
GROUP BY race
ORDER BY race;
							
				--	  	/race	/all_payers_c /registred_users/race_payers_share 
				--		Angel		229	 			1327		0.1726
				--		Demon		238	 			1229		0.1937
				--		Elf			427				2501		0.1707
				--		Hobbit		659				3648		0.1806
				--		Human		1114			6328		0.1760
				--		Northman	626				3562		0.1757
				--		Orc			636				3619		0.1757



-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
-- Напишите ваш запрос здесь
SELECT 
	COUNT(amount) AS all_amount, 
	SUM(amount) AS sum_amount,
	MIN(amount) AS min_amount,
	MAX(amount) AS max_amount,
	ROUND(AVG(amount :: NUMERIC),2) AS avg_amount,
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY amount) AS median,
	ROUND(STDDEV(amount::NUMERIC),2) AS standard_dev
FROM fantasy.events e ;

				--all_amount	sum_amount	min_amount		max_amount	avg_amount	 median		standard_dev
			--		1307678		686615040	  0.0			 486615.1	  525.69	  74.86	   	  2517.35


-- 2.2: Аномальные нулевые покупки:
-- Напишите ваш запрос здесь

--WITH counts AS (
--SELECT COUNT(amount) AS amount_with_zero,   				-- абсолютное количество  покупки с нулевой стоимостью
--	   (SELECT COUNT(amount) FROM fantasy.events e) AS all_amount   
--FROM fantasy.events e
--WHERE amount = 0
--)
--SELECT amount_with_zero, CAST(amount_with_zero AS NUMERIC)/all_amount AS share_with_zero_amount --доля от общего числа покупок
--FROM counts;

SELECT COUNT(amount) AS amount_with_zero, 
(COUNT(amount)::FLOAT / (SELECT COUNT(amount) FROM fantasy.events)) AS share_with_zero_amount 
FROM fantasy.events 
WHERE amount = 0;
			-- amount_with_zero				share_with_zero_amount
			--		907			  			0.00069359582404842782


-- 2.3: Сравнительный анализ активности платящих и неплатящих игроков:
-- Напишите ваш запрос здесь
--WITH queries AS (
--    SELECT e.id, 
--        COUNT(*) AS purch_count,  
--        SUM(e.amount) AS tot_amount  
--    FROM fantasy.events e
--    WHERE e.amount > 0  		-- исключаем бесплатные покупки
--    GROUP BY e.id
--)
--SELECT 
--	CASE 
--		WHEN payer = 0 THEN 'неплатящие'
--		WHEN payer = 1 THEN 'платящие'
--	END,
--    COUNT(DISTINCT id) AS total_players, 
--    ROUND(AVG(q.purch_count),2) AS avg_purch_player,  
--    ROUND(AVG(q.tot_amount)) AS avg_spent_player  
--FROM fantasy.users u
--JOIN queries AS q USING(id)
--GROUP BY u.payer;

SELECT 
	CASE 
		WHEN payer = 0 THEN 'неплатящие'
		WHEN payer = 1 THEN 'платящие'
	END,
    COUNT(DISTINCT id) AS total_players, 
    ROUND(COUNT(e.id)::NUMERIC / COUNT(DISTINCT e.id) ,2) AS avg_purch_player,  
    ROUND(SUM(e.amount)::NUMERIC / COUNT(DISTINCT e.id),2 ) AS avg_spent_player  
FROM fantasy.users u
JOIN fantasy.events AS e USING(id)
GROUP BY u.payer;
								--			total_players   avg_purch_player  avg_spent_player
								--неплатящие	11348			97.56			48632.0
								--платящие		2444			81.68			55468.0


-- 2.4: Популярные эпические предметы:
-- Напишите ваш запрос здесь
--SELECT 
--	i.game_items,
--	COUNT(e.item_code) AS item_count,
--	ROUND(COUNT(e.item_code)/(					
--								SELECT								--subquery общего количества покупок 
--									COUNT(*) AS all_purchases
--									FROM fantasy.events
--									WHERE amount > 0)::NUMERIC,5
--								) AS shares_purch,					-- доля продажи каждого предмета от всех продаж
--	COUNT(DISTINCT e.id) AS users,
--	ROUND(COUNT(DISTINCT id)/(										-- количество пользователей 
--					SELECT 
--						COUNT(DISTINCT id) AS all_payers			-- subquery для количество пользователей совершивших хотя-бы одну покупку
--					    FROM fantasy.events 
--					    WHERE amount > 0
--					    )::NUMERIC, 5
--					) AS payer_share
--FROM fantasy.items i 
--JOIN fantasy.events e USING(item_code)
--WHERE e.amount > 0 													-- Фильтр на платные покупки
--GROUP BY i.game_items
--ORDER BY item_count DESC; 

SELECT i.game_items,
       COUNT(e.item_code) AS item_count,
       ROUND(COUNT(e.item_code)/
               (SELECT --subquery общего количества покупок
 COUNT(*) AS all_purchases
                FROM fantasy.events
                WHERE amount > 0)::NUMERIC, 5) AS shares_purch, -- доля продажи каждого предмета от всех продаж
 COUNT(DISTINCT e.id) AS users,
 ROUND(COUNT(DISTINCT id)/
         (-- количество пользователей
 SELECT COUNT(DISTINCT id) AS all_payers -- subquery для количество пользователей совершивших хотя-бы одну покупку

          FROM fantasy.events
          WHERE amount > 0)::NUMERIC, 5) AS payer_share
FROM fantasy.items i
JOIN fantasy.events e USING(item_code)
WHERE e.amount > 0 -- Фильтр на платные покупки
GROUP BY i.game_items
ORDER BY item_count DESC;


-- game_items					item_count		  shares_purch			users			payer_share
--Book of Legends				1004516				0.76870				12194			0.88414
--Bag of Holding				271875				0.20805				11968			0.86775
--Necklace of Wisdom			13828				0.01058				1627			0.11797
--Gems of Insight				3833				0.00293				926				0.06714
--Treasure Map					3183				0.00244				819				0.05938
--Amulet of Protection			1078				0.00082				445				0.03227
--Silver Flask					795					0.00061				633				0.04590
--Strength Elixir				580					0.00044				331				0.02400



-- Часть 2. Решение ad hoc-задач
-- Задача 1. Зависимость активности игроков от расы персонажа:
-- Напишите ваш запрос здесь
WITH reg_users AS (
SELECT 
    race_id,
    race,
    COUNT(id) AS total_users  -- Общее количество зарегистрированных игроков для каждой расы
FROM fantasy.users
JOIN fantasy.race r USING(race_id)
GROUP BY race_id, race
),
buy_users AS (
SELECT 
    u.race_id,
    r.race,
    r.total_users,
    COUNT(DISTINCT e.id) AS buyers_count, 									 -- Количество игроков, совершивших хотя бы одну покупку
    ROUND(COUNT(DISTINCT e.id)::NUMERIC / r.total_users, 4) AS share_buyer   -- Доля игроков, совершивших покупки
FROM fantasy.events e
JOIN fantasy.users u USING(id)
JOIN reg_users r USING(race_id)
WHERE e.amount > 0
GROUP BY u.race_id, r.total_users, r.race
),
paying_users AS (
SELECT 
    u.race_id,
    COUNT(DISTINCT e.id) AS paying_buyers_count  -- Количество платящих игроков (те, кто действительно заплатил)
FROM fantasy.events e
JOIN fantasy.users u USING(id)
WHERE e.amount > 0 AND u.payer = 1
GROUP BY u.race_id
)
SELECT 
    b.race,
    b.total_users,
    b.buyers_count,
    b.share_buyer,
    ROUND(pu.paying_buyers_count::NUMERIC / b.buyers_count, 4) AS paying_buyer_share,   -- Доля платящих игроков от всех покупателей
    ROUND(COUNT(e.id) / b.buyers_count::NUMERIC, 2) AS avg_purch_buyer, 		-- Среднее количество покупок на одного игрока
    ROUND(SUM(e.amount)::NUMERIC / COUNT(e.id), 2) AS avg_purch_price,				-- Средняя стоимость одной покупки
    ROUND(SUM(e.amount)::NUMERIC / b.buyers_count, 2) AS avg_total_buyer 		-- Средняя суммарная стоимость всех покупок на одного игрока
FROM fantasy.events e 
JOIN fantasy.users u USING(id)
JOIN buy_users b USING(race_id)
JOIN paying_users pu USING(race_id)
WHERE e.amount > 0
GROUP BY b.race, b.total_users, b.buyers_count, b.share_buyer, pu.paying_buyers_count
ORDER BY total_users DESC;

--		race		total_users	  buyers_count	share_buyer	  paying_buyer_share  avg_purch_buyer    avg_purch_price	avg_total_buyer
--		Human			6328		3921			0.6196		0.1801				121.40				403.07				48933.69
--		Hobbit			3648		2266			0.6212		0.1770				86.13				552.91				47621.80
--		Orc				3619		2276			0.6289		0.1740				81.74				510.92				41761.69
--		Northman		3562		2229			0.6258		0.1821				82.10				761.48				62519.07
--		Elf				2501		1543			0.6170		0.1627				78.79				682.33				53761.24
--		Angel			1327		820				0.6179		0.1671				106.80				455.64				48664.63
--		Demon			1229		737				0.5997		0.1995				77.87				529.02				41194.44




-- Задача 2: Частота покупок
-- Напишите ваш запрос здесь

WITH purchases AS (
SELECT 
    id AS user_id,
    (date::date - LAG(date::date) OVER (PARTITION BY id ORDER BY date::date)) AS since_last_purchase,
    amount
FROM fantasy.events
WHERE amount > 0 
),
purchase_stats AS (
SELECT 
    user_id,
    COUNT(*) AS total_purchases, 
    ROUND(AVG(since_last_purchase),2) AS days_bet_purch,
    MAX(CASE WHEN amount > 0 AND u.payer = 1 THEN 1 ELSE 0 END) AS paying_user
FROM purchases p
JOIN fantasy.users u ON p.user_id = u.id
WHERE since_last_purchase IS NOT NULL
GROUP BY user_id
HAVING COUNT(*) >= 25
),
ranked_users AS (
SELECT 
    user_id,
    total_purchases,
    days_bet_purch,
    paying_user,
    NTILE(3) OVER (ORDER BY days_bet_purch) AS rank3 --разбиваем на 3 группы
    FROM purchase_stats
),
grouped_stats AS (
SELECT 
    CASE 
    WHEN rank3 = 1 THEN 'Высокая частота'
    WHEN rank3 = 2 THEN 'Умеренная частота'
    WHEN rank3 = 3 THEN 'Низкая частота'
    END AS freq_cat,
    COUNT(user_id) AS total_players, 									-- Количество игроков в группе
    SUM(paying_user) AS paying_players,									 -- Количество платящих игроков
    ROUND(SUM(paying_user)::NUMERIC / COUNT(user_id), 2) AS paying_share, -- Доля платящих игроков
    ROUND(AVG(total_purchases), 2) AS avg_purchases, 						-- Среднее число покупок на игрока
    ROUND(AVG(days_bet_purch), 2) AS days_bet_purch 					-- Средний интервал между покупками
FROM ranked_users
GROUP BY rank3
)
SELECT * FROM grouped_stats
ORDER BY days_bet_purch;
--freq_cat				total_players  paying_players   paying_share   avg_purchases   days_bet_purch
--Высокая частота			2514			461				0.18			396.91			3.24
--Умеренная частота			2514			442				0.18			58.95			7.39
--Низкая частота			2514			432				0.17			33.66			12.91
