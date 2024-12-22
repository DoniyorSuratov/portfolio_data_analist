SELECT * FROM public.parcing_table LIMIT 20;

-- диапазон заработных плат в общем, а именно средние значения, минимумы и максимумы нижних и верхних порогов зарплаты.
SELECT 
min(salary_from) AS min_salary_from,
max(salary_from) AS max_salary_from,
round(avg(salary_from),2) AS avg_salary_from, 
min(salary_to) AS min_salary_to,
max(salary_to) AS max_salary_to,
round(avg(salary_to),2) AS avg_salary_to
FROM public.parcing_table;

-- Регионы и компании, в которых сосредоточено наибольшее количество вакансий.
SELECT area, count(*) AS number_of_vacancies 
FROM  public.parcing_table
GROUP BY area  
ORDER BY number_of_vacancies DESC;

-- Количество вакансий по компаниям
SELECT employer, count(*) number_of_vacancies
FROM public.parcing_table
GROUP BY employer 
ORDER BY number_of_vacancies DESC;


-- Количество вакансий по типу занятости
SELECT employment,
       COUNT(*) AS num_vacancies
FROM public.parcing_table 
GROUP BY employment 
ORDER BY num_vacancies DESC;


-- Количество вакансий по графику работы
SELECT schedule,
       COUNT(*) AS num_vacancies 
FROM public.parcing_table 
GROUP BY schedule 
ORDER BY num_vacancies DESC;


-- Выявление грейда требуемых специалистов по опыту
--SELECT experience, count(*) AS num_vacancies 
--FROM public.parcing_table
--GROUP BY experience
--ORDER BY num_vacancies DESC;


-- Определение доли грейдов среди вакансий аналитиков
SELECT COUNT(*) 
FROM public.parcing_table 
WHERE name LIKE '%Аналитик данных%' 
   OR name LIKE '%Системный аналитик%';

-- Результат - 1157. 
-- 2) Теперь используем это число чтобы рассчитать доли:

SELECT experience,
    COUNT(*) AS num_vacancies,
    ROUND(COUNT(*) * 100.0 / 1157, 2) AS percent_vacancies
	FROM public.parcing_table
	WHERE name LIKE '%Аналитик данных%' 
    OR name LIKE '%Системный аналитик%'
GROUP BY experience
ORDER BY percent_vacancies DESC;



-- основныe работодатели, предлагаемые зарплаты и условия труда для аналитиков.
SELECT employer,
       COUNT(*) AS num_vacancies,
       ROUND(AVG(salary_from), 2) AS avg_salary_from,
       ROUND(AVG(salary_to), 2) AS avg_salary_to,
       employment,
       schedule
FROM public.parcing_table 
WHERE name LIKE '%Аналитик данных%' OR name LIKE '%Системный аналитик%'
GROUP BY employer, employment, schedule 
ORDER BY num_vacancies DESC;


-- наиболее востребованные навыки (как жёсткие, так и мягкие) для различных грейдов и позиций.
SELECT experience, 
    MAX(key_skills_1) AS max_hard_skills1, 
    MAX(key_skills_2) AS max_hard_skills2,
    MAX(key_skills_3) AS max_hard_skills3, 
    MAX(key_skills_4) AS max_hard_skills4,
    MAX(soft_skills_1) AS max_soft_skills1, 
    MAX(soft_skills_2) AS max_soft_skills2,
    MAX(soft_skills_3) AS max_soft_skills3, 
    MAX(soft_skills_4) AS max_soft_skills4
FROM public.parcing_table
GROUP BY experience;


-- Частота упоминания hard и soft skills
SELECT key_skills_1,
       COUNT(*) AS num_mention
FROM public.parcing_table 
GROUP BY key_skills_1 
ORDER BY num_mention DESC;


