select *
From [Portfolio Project]..CovidDeaths
Order by 3,4

select *
From [Portfolio Project]..['Covid Vaccination]
Order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
From [Portfolio Project]..CovidDeaths
Order by 1,2

--Looking at total Cases Vs Total Deaths as Percentage

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Order by 1,2

--Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where location like 'Nepal'
Order by 5 desc

--Total Cases Vs Total Population (United States)
--shows what percentage of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage
From [Portfolio Project]..CovidDeaths
Where location like 'United States'
Order by 2

--Countries with highest infection rate compared to population

select location,population,Max(total_cases)as HighestInfectionCount,Max((total_cases/population)*100)  as CovidPercentage
From [Portfolio Project]..CovidDeaths
Group by location,population
Order by CovidPercentage desc


--Showing countries with highest death count

select location,Max(cast(total_deaths as int))as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Group by location
Order by TotalDeathCount desc


--Joining two tables and find new vaccinations in different countries with time

Select d.continent, d.location,d.date,d.population, v.new_vaccinations
From [Portfolio Project]..CovidDeaths as d
Join [Portfolio Project]..['Covid Vaccination] as v
 On d.location=v.location
 and d.date=v.date
 where d.continent is not null
 order by 2,3

--Looking at Total Population Vs vaccinations

Select d.continent, d.location,d.date,d.population, v.new_vaccinations, Sum(Cast(v.new_vaccinations as int)) over (partition by d.location  order by d.date)as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths as d
Join [Portfolio Project]..['Covid Vaccination] as v
 On d.location=v.location
 and d.date=v.date
 where d.continent is not null
  order by 2,3

  --USE CTE
 With PopVsVac(Continent, location,date,Population,New_Vaccinations, RollingPeopleVaccinated)
 as
 (Select d.continent, d.location,d.date,d.population, v.new_vaccinations, Sum(Cast(v.new_vaccinations as int)) over (partition by d.location  order by d.date)as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths as d
Join [Portfolio Project]..['Covid Vaccination] as v
 On d.location=v.location
 and d.date=v.date
 where d.continent is not null
 --order by 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
 from PopVsVac