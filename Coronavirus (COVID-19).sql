use covide_sql_project;
select * from coviddeaths;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT 
    location,  
    SUM(total_cases) as total_cases,
    SUM(total_deaths) as total_deaths, 
    round(((SUM(total_deaths) / SUM(total_cases)) * 100),2) as percentage_of_death 
FROM 
    coviddeaths 
GROUP BY 
    location 
ORDER BY 
    percentage_of_death DESC;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT 
  distinct location,
   population,
   sum(total_cases) as total_cases,
   round(((sum(total_cases)/population)*100),2) as percentage_of_afectation
from coviddeaths
group by location, population;

-- Countries with Highest Infection Rate compared to Population
SELECT 
  distinct location,
   max(population) as max_population ,
   sum(new_cases)as total_cases,
   round(((sum(new_cases)/population)*100),2) as percentage_of_afectation
from coviddeaths
group by location ,population
order by percentage_of_afectation desc;

-- Countries with Highest Death Count per Population

#conver the total_deaths column from text to int

  # set the null value to all empty cellul in the column
UPDATE coviddeaths
SET total_deaths = NULL
WHERE total_deaths = '' ;

   # now change the data type from text to int
ALTER TABLE coviddeaths
MODIFY COLUMN total_deaths INT;

 # result
SELECT 
  location,
   population,
   max(total_deaths)as total_deaths
from coviddeaths
group by location ,population
order by total_deaths desc; 


-- Showing contintents with the highest death count per population
SELECT 
  distinct continent,
   max(population) as population,
   max(total_deaths)as total_deaths
from coviddeaths
where continent is not null
group by continent 
order by total_deaths desc;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select cv.location , cd.population , max(cv.total_vaccinations) as total_vaccination,
round(((max(cv.total_vaccinations)/cd.population)*100),3) as percentage
from coviddeaths cd
inner join covidvaccinations cv
on cd.location = cv.location
where cv.location is not null
group by cv.location , cd.population
order by percentage asc;



-- ---------------------------------------------------------------------
Create View percentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

