--[[
This module provides routines for the calculation of
Gregorian days
]]

---
-- Module calendar
-- handles calendar information for any language
-- which has a resource file.
-- Resource files are based on CLDR
-- Y Lazarides
-- 2014
-- version 1.0
-- Licence: cc0
-- 

local m = m or {}
m.language = {}
m.language.default = 'English'

m.days = {'Ming', 'Sen', 'Sel', 
  'Rab', 'Kam', 'Jum', 'Sab'}
m.months = {'Januari', 'Februari', 'Maret', 
  'April', 'Mei','Juni',
  'Juli', 'Agustus', 'September', 
  'Oktober', 'November', 'Desember'}

m.months.images = {
  "satu.jpg", "dua.jpg", "tiga.jpg", 
  "empat.jpg", "lima.jpg", "enam.jpg",
  "tujuh.jpg", "delapan.jpg", "sembilan.jpg", 
  "sepuluh.jpg", "sebelas.jpg", "duabelas.jpg",
  }

m.options = {
  box_width = "2.1em",  
  bidi = "LTR",
  font = "",
  days_in_row = 14,
  previous_month_color = 'gray',
  next_month_color = 'gray',
  first_day_of_week = 1,
  first_day_of_week_color = "red",
}    


if tex ~=nil then print = tex.print end
-- sets the default language. This needs to be captured
-- from document.config

m.setLanguageDefault = function (language)
  m.language.default = language
end 

m.getLanguageDefault = function ()
  return m.language.default
end  



--- Calculate the Julian Day
-- Julian Day
function julianDay (year, month, Day, julian)
  local A, B, JD 
  if month<2 then
    year = year-1
    month = month + 12
  end
  A = math.floor(year/100)
  if not julian then
    B = 2 - A + math.floor(A/4)
  else
    B =0
  end
  JD = math.floor(365.25*(year+4716)) + 
  math.floor(30.6001*(month+1)) + Day + B - 1524.5
  return JD
end

-- @return JD as per wikipedia algorithm
-- 
function gregorianToJulianDay(year, month, day)
  local floor = math.floor
  local JD 
  local a = floor((14-month)/12)
  year = year + 4800 -a
  month = month + 12*a -3
  JD = day + floor((153*month+2)/5) + 365*year + floor(year/4) 
  - floor(year/100) + floor(year/400) -32045
  return JD
end  

--print('Julian Day',julianDay(2006, 8, 15.0, false))
--print(julianDay(2006, 10, 4.00, false))
--print(gregorianToJulianDay(2006, 8, 15.5))
--print(julianDay(333, 1, 27, true))
--print(julianDay(2000, 1, 1.5, false))
--print(julianDay(837, 4, 10.3, true))
--print(julianDay(-1000, 2, 29, true))




-- function getDaysOfMonth calculates how many
-- days are in a particular month
-- taking into account leap years
-- based on Gregorian calendar
-- @arg month
-- @arg year
local function getDaysOfMonth(month, year)
  local days = 31
  if month==4 or month==6 or month ==9 or month ==11 then
    days = 30
  else
    if month == 2 then 
      days = 28
      if (math.fmod(year, 4)) == 0 and (math.fmod(month,100)) ~= 0 
      and math.fmod(year,400)~=0 then -- 'leap year'
        days = 29  
      end
    end

  end  
  return days
end 


-- returns the day of week integer and the name of the week
-- Compatible with Lua 5.0 and 5.1.
-- from sam_lie on Lua Wiki
local function getDayOfWeek(dd, mm, yy) 
  days = m.days -- based on sunday as day =1

  local mmx = mm

  if (mm == 1) then  mmx = 13; yy = yy-1  end
  if (mm == 2) then  mmx = 14; yy = yy-1  end

  local val8 = dd + (mmx*2) +  math.floor(((mmx+1)*3)/5)  
  + yy + math.floor(yy/4)  - math.floor(yy/100)  
  + math.floor(yy/400) + 2

  local val9 = math.floor(val8/7)

  local dw = val8-(val9*7) 

  if (dw == 0) then
    dw = 7
  end

  return dw, days[dw]
end


function perpetualCalendar(mm,yy,istart,iend)
  local v = {}   -- vector to store day of month
  local j = 1
  for i= istart, iend do
    v[j] = i
    j=j+1
  end 
  return v  -- returns vector 26,27,28 etc
end

-- The main function fill a vector of 42 cells to print a 
-- Perpetual calendar. 
-- su mon tu we th fri sat
-- we need to get values both from the previous month
-- as well as the current month
-- options are for styling
-- @arg days the day object
-- 
printCalendarWeekLabel = function (days, mm, year, opts)
  local options= m.options or {}
  local days_in_row = options.days_in_row
  local j =1
  local s1=''
  local s2='' 
  print("\\begin{scriptexample}[colback=black]{} \\raggedright\\par")
  print([[\centering\includegraphics[width=\textwidth,height=25cm,keepaspectratio]{./images/]]..m.months.images[mm]..[[}%
              \\par
              \\vspace*{3pt}%]])
  print('\\par {\\color{white}\\bfseries '..m.months[mm]..' '..year..'\\vskip3pt}')
  for i=1, days_in_row do
    if i>7 then j=i-7 end
    if j == m.options.first_day_of_week then
      s1 =[[\color{]]..m.options.first_day_of_week_color..[[}]]
      s2 =[[\color{white}]]  
    else
      s1 = [[\color{white}]] 
      s2 = ''
    end

    print('\\makebox['..options.box_width..']{\\hfill '..s1..days[j]..s2..'} %')
    j = j+1
  end  
  print("\\par")
end



function mainPerpetualCalendar (mm, yy)
  -- first we get the days in the month, as well as the 
  -- first weekday of the month
  local monthdays, dw = getDaysOfMonth(mm,yy), getDayOfWeek(1,mm,yy)
  local currentmonth = mm
  local currentyear = yy
  local previousyear = yy - 1
  local nextyear = yy + 1
  local count = 1
  if dw>1 then --print('day of week =', dw) -- we need previous month
    local previousmonth 
    if mm==1 then previousmonth = 12 -- caters for January
      previousyear = yy-1
    end
  else
    previousmonth = mm-1
    yy = currentyear
  end


  local vector = {}
  -- we use a vector to hold the 42 days in the month
  -- we need to print portion of previous month calendar

  local x1 = getDaysOfMonth(previousmonth, yy)-(dw-2) 
  local x2 = getDaysOfMonth(previousmonth, yy)

  vector = perpetualCalendar(previousmonth,yy, x1, getDaysOfMonth(previousmonth,yy)) 

  -- call for current month
  local vector2 = perpetualCalendar(currentmonth, currentyear, 1, 
    getDaysOfMonth(currentmonth, currentyear))

  for i=0, dw+monthdays  do
    vector [dw+i] = vector2[i]

  end


-- There are 42 cells in a typical calendar, so we need to get the days
-- in the following month

  local offset = 43-count -- these are from the beginning of next month

  for k,v in pairs(vector) do
    count = count+1
  end

  local z =1
  for i = count+1, 43 do
    vector[i] = z  -- at end calendar dates start 1,2,3,4
    z=z+1

  end  


  printCalendarWeekLabel(days, currentmonth, currentyear, {a="zz"})

  count = 0
  for k,v in pairs(vector) do 
    print('\\makebox['..m.options.box_width..']{\\hfill\\color{white} '..vector[k]..'} %') 
    count = count +1
    if count == m.options.days_in_row then 
      print("\\par") 
      count = 0 
    end
  end

  print("\\end{scriptexample}\\par")


end -- close function



m.makeCalendar = function (mm, yy)
  mainPerpetualCalendar(mm, yy)
end

m.yearCalendar = function (yy)
  for i=1, 12 do
    mainPerpetualCalendar(i, yy) 
  end
end

-- m.makeCalendar(2, 2015)
local i, n = getDayOfWeek(1,1,2007)
assert(i == 2 and n == 'Mon')
assert(getDayOfWeek(2,1,2007) == 3)
assert(getDayOfWeek(3,1,2007) == 4)
assert(getDayOfWeek(4,1,2007) == 5)
assert(getDayOfWeek(5,1,2007) == 6)
assert(getDayOfWeek(6,1,2007) == 7)
assert(getDayOfWeek(7,1,2007) == 1)
assert(getDayOfWeek(1,2,2007) == 5)


return m





