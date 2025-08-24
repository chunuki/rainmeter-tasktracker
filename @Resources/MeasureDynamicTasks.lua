-- MeasureDynamicTasks.lua
-- Copyright (C) 2025 dcyx

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/>.


function Initialize()

	sDynamicMeterFile = SELF:GetOption('DynamicMeterFile')
	sTaskListFile = SELF:GetOption('TaskListFile')
	sSettingsFile = SELF:GetOption('SettingsFile')
	sAlignment = SELF:GetOption('Alignment')
	sTaskWidth = SELF:GetOption('TaskWidth')

	hFile = io.open(sSettingsFile, "r")
	sortToggle = hFile:read("*l")
	hFile:close()
	
end

function ButtonInit()

	dynamicOutput[#dynamicOutput + 1] = "FontFace=FontAwesome"
	dynamicOutput[#dynamicOutput + 1] = "FontSize=16"
	dynamicOutput[#dynamicOutput + 1] = "SolidColor=0,0,0,1"
	dynamicOutput[#dynamicOutput + 1] = "AntiAlias=1"
	dynamicOutput[#dynamicOutput + 1] = "ClipString=1"

end

function GetCurrentDate()

    local currentDate = os.time()
    return os.date("%d/%m/%y", currentDate)

end

function Update()

	dynamicOutput = {}
	tasks = {}
	header = ""
	checked = ""
	recurring = ""
	timed = ""

	-- Iterate through each line in the task list
	for line in io.lines(sTaskListFile) do

		-- check for header
		if string.match(line, "^%d%d/%d%d/%d%d$") then
			header = header.."|"..#tasks+1
		end

		-- check if the task is complete
		if string.sub(line,1,1) == "+" then 
			checked = checked.."|"..#tasks+1
			line = string.sub(line,2,string.len(line))
		end

		-- check if the task is recurring
		if string.sub(line,-2,-1) == "|R" then
			recurring = recurring.."|"..#tasks+1
			line = string.sub(line,1,-3)
		end

		-- check is the task is timed
		if string.match(string.sub(line,1,4), "^%d%d%d%d$") then
			timed = timed.."|"..#tasks+1
		end

		tasks[#tasks + 1] = line

	end

	-- add delimeters
	header = header.."|"
	checked = checked.."|"
	recurring = recurring.."|"
	timed = timed.."|"

	-- dynamic meters
	for i=1,#tasks,1 do
		-- check for headers and find correct header for current date
		if string.find(header, "|"..i.."|") ~= nil then
			if tasks[i] == GetCurrentDate() then
				-- add new header
				dynamicOutput[#dynamicOutput + 1] = "[MeterTaskIcon"..i.."]"
				dynamicOutput[#dynamicOutput + 1] = "Meter=String"
				dynamicOutput[#dynamicOutput + 1] = "[MeterHeader]"
				dynamicOutput[#dynamicOutput + 1] = "Meter=String"
				dynamicOutput[#dynamicOutput + 1] = "Text="..tasks[i]
				dynamicOutput[#dynamicOutput + 1] = "FontFace=Roboto"
				dynamicOutput[#dynamicOutput + 1] = "FontSize=20"
				dynamicOutput[#dynamicOutput + 1] = "FontColor=255,255,255,255"
				dynamicOutput[#dynamicOutput + 1] = "StringStyle=Bold"
				dynamicOutput[#dynamicOutput + 1] = "AntiAlias=1"
				dynamicOutput[#dynamicOutput + 1] = "ClipString=1"
				dynamicOutput[#dynamicOutput + 1] = "X=0"
				dynamicOutput[#dynamicOutput + 1] = "Y=R"
				dynamicOutput[#dynamicOutput + 1] = "W="..sTaskWidth
			else
				break
			end
		else
			dynamicOutput[#dynamicOutput + 1] = "[MeterTaskIcon"..i.."]"
			dynamicOutput[#dynamicOutput + 1] = "Meter=String"

			-- checkbox
			if string.find(checked, "|"..i.."|") ~= nil then
				dynamicOutput[#dynamicOutput + 1] = "Text=[\\[#fa-check-sq]]"
			else
				dynamicOutput[#dynamicOutput + 1] = "Text=[\\[#fa-sq]]"
			end
			dynamicOutput[#dynamicOutput + 1] = "FontFace=FontAwesome"
			dynamicOutput[#dynamicOutput + 1] = "FontSize=18"
			dynamicOutput[#dynamicOutput + 1] = "FontColor=255,255,255,255"
			dynamicOutput[#dynamicOutput + 1] = "SolidColor=0,0,0,1"
			dynamicOutput[#dynamicOutput + 1] = "AntiAlias=1"
			dynamicOutput[#dynamicOutput + 1] = "ClipString=1"
			dynamicOutput[#dynamicOutput + 1] = "X=0"
			dynamicOutput[#dynamicOutput + 1] = "Y=R"
			dynamicOutput[#dynamicOutput + 1] = "H=24"
			dynamicOutput[#dynamicOutput + 1] = "W=30"
			dynamicOutput[#dynamicOutput + 1] = "LeftMouseUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"CheckLine("..i..")\"][!Refresh][!Refresh]"
			dynamicOutput[#dynamicOutput + 1] = "DynamicVariables=1"
			
			-- task text
			dynamicOutput[#dynamicOutput + 1] = "[MeterRepeatingTask"..i.."]"
			dynamicOutput[#dynamicOutput + 1] = "Meter=String"
			dynamicOutput[#dynamicOutput + 1] = "Text="..tasks[i]
			dynamicOutput[#dynamicOutput + 1] = "FontFace=Roboto"
			dynamicOutput[#dynamicOutput + 1] = "FontSize=16"
			dynamicOutput[#dynamicOutput + 1] = "FontColor=255,255,255,255"
			dynamicOutput[#dynamicOutput + 1] = "SolidColor=0,0,0,1"
			dynamicOutput[#dynamicOutput + 1] = "StringStyle=Bold"
			dynamicOutput[#dynamicOutput + 1] = "AntiAlias=1"
			dynamicOutput[#dynamicOutput + 1] = "ClipString=1"
			dynamicOutput[#dynamicOutput + 1] = "X=R"
			dynamicOutput[#dynamicOutput + 1] = "Y=r"
			dynamicOutput[#dynamicOutput + 1] = "H=24"
			dynamicOutput[#dynamicOutput + 1] = "W="..sTaskWidth
		end
	end

	-- include Font Awesome icons
	dynamicOutput[#dynamicOutput + 1] = "@Include=#@#FontAwesome.inc"

	-- refresh button
	dynamicOutput[#dynamicOutput + 1] = "[MeterRefreshTasks]"
	dynamicOutput[#dynamicOutput + 1] = "Meter=String"
	dynamicOutput[#dynamicOutput + 1] = "Text=[\\[#fa-refresh]]"
	dynamicOutput[#dynamicOutput + 1] = "X=0"
	dynamicOutput[#dynamicOutput + 1] = "Y=15R"
	dynamicOutput[#dynamicOutput + 1] = "W=30"
	dynamicOutput[#dynamicOutput + 1] = "FontColor=255,255,255,255"
	ButtonInit()
	dynamicOutput[#dynamicOutput + 1] = "LeftMouseUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"SortTasks()\"][!Refresh][!Refresh]"

	-- reset button
	dynamicOutput[#dynamicOutput + 1] = "[MeterUndoTasks]"
	dynamicOutput[#dynamicOutput + 1] = "Meter=String"
	dynamicOutput[#dynamicOutput + 1] = "Text=[\\[#fa-undo]]"
	dynamicOutput[#dynamicOutput + 1] = "X=R"
	dynamicOutput[#dynamicOutput + 1] = "Y=r"
	dynamicOutput[#dynamicOutput + 1] = "W=30"
	dynamicOutput[#dynamicOutput + 1] = "FontColor=255,255,255,255"
	ButtonInit()
	dynamicOutput[#dynamicOutput + 1] = "LeftMouseUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"ResetAll()\"][!Refresh][!Refresh]"

	-- add button
	dynamicOutput[#dynamicOutput + 1] = "[MeterAddTasks]"
	dynamicOutput[#dynamicOutput + 1] = "Meter=String"
	dynamicOutput[#dynamicOutput + 1] = "Text=[\\[#fa-plus-sq]]"
	dynamicOutput[#dynamicOutput + 1] = "X=R"
	dynamicOutput[#dynamicOutput + 1] = "Y=r"
	dynamicOutput[#dynamicOutput + 1] = "W=30"
	dynamicOutput[#dynamicOutput + 1] = "FontColor=255,255,255,255"
	ButtonInit()
	dynamicOutput[#dynamicOutput + 1] = "LeftMouseUpAction=[!CommandMeasure MeasureInput \"ExecuteBatch 1-2\"]"

	-- file button
	dynamicOutput[#dynamicOutput + 1] = "[MeterFile]"
	dynamicOutput[#dynamicOutput + 1] = "Meter=String"
	dynamicOutput[#dynamicOutput + 1] = "Text=[\\[#fa-file]]"
	dynamicOutput[#dynamicOutput + 1] = "X=R"
	dynamicOutput[#dynamicOutput + 1] = "Y=r"
	dynamicOutput[#dynamicOutput + 1] = "W=30"
	dynamicOutput[#dynamicOutput + 1] = "FontColor=255,255,255,255"
	ButtonInit()
	local filePath = sTaskListFile
	if filePath ~= nil then
		dynamicOutput[#dynamicOutput + 1] = 'LeftMouseUpAction=["' .. filePath .. '"]'
	end

	-- sort toggle button
	dynamicOutput[#dynamicOutput + 1] = "[MeterSortToggle]"
	dynamicOutput[#dynamicOutput + 1] = "Meter=String"
	dynamicOutput[#dynamicOutput + 1] = "Text=[\\[#fa-chevron-circle-up]]"
	dynamicOutput[#dynamicOutput + 1] = "X=R"
	dynamicOutput[#dynamicOutput + 1] = "Y=r"
	dynamicOutput[#dynamicOutput + 1] = "W=30"
	ButtonInit()
	if sortToggle == "false" then
		dynamicOutput[#dynamicOutput + 1] = "FontColor=255,255,255,100"
	else
		dynamicOutput[#dynamicOutput + 1] = "FontColor=255,255,255,255"
	end
	dynamicOutput[#dynamicOutput + 1] = "LeftMouseUpAction=[!CommandMeasure \"MeasureDynamicTasks\" \"SortToggle()\"][!Refresh][!Refresh]"

	-- create dynamic meter file
	local File = io.open(sDynamicMeterFile, 'w')

	-- error handling
	if not File then
		print('Update: unable to open file at ' .. sDynamicMeterFile)
		return
	end

	output = table.concat(dynamicOutput, '\n')

	File:write(output)
	File:close()
	
end

function SortToggle()

	local hFile = io.open(sSettingsFile, "w")

	if sortToggle == "true" then hFile:write("false")
	elseif sortToggle == "false" then hFile:write("true")
	end

	hFile:close()

end

function SortTasks()

	CheckDate()

	local hFile = io.open(sTaskListFile, "r")
	local timedTasks = {}
	local untimedTasks = {}
	local cTimedTasks = {}
	local cUntimedTasks = {}
	local currentDate = ""
	local dateOrder = {}
	local dateToTasks = {}

	-- read through task list
	for line in hFile:lines() do

		-- check for date
		if string.match(line, "^%d%d/%d%d/%d%d$") then

			-- prepare task list for that date
			currentDate = line
			dateOrder[#dateOrder+1] = line
			dateToTasks[currentDate] = {}

		else

			if line ~= "" then
				dateToTasks[currentDate][#dateToTasks[currentDate]+1] = line
			end

		end
	end

	hFile:close()

	-- find the task list for the current date
	for date, taskList in pairs(dateToTasks) do

		if date == GetCurrentDate() then

			-- check for timed/untimed completed/uncompleted tasks and add into respective lists
			for _, task in ipairs(taskList) do

				if string.match(string.sub(task,2,5), "^%d%d%d%d$") then
					cTimedTasks[#cTimedTasks+1] = task
				elseif string.match(string.sub(task,1,1), "+") then
					cUntimedTasks[#cUntimedTasks+1] = task
				elseif string.match(string.sub(task,1,4), "^%d%d%d%d$") then
					timedTasks[#timedTasks+1] = task
				else
					untimedTasks[#untimedTasks+1] = task
				end

			end

			-- empty current date's task list
			dateToTasks[date] = {}

			-- sort timed tasks
			table.sort(cTimedTasks)
			table.sort(timedTasks)

			-- recreate current date's task list in sorted order
			for _, cUntimedTask in ipairs(cUntimedTasks) do
				dateToTasks[date][#dateToTasks[date]+1] = cUntimedTask
			end
			for _, cTimedTask in ipairs(cTimedTasks) do
				dateToTasks[date][#dateToTasks[date]+1] = cTimedTask
			end
			for _, untimedTask in ipairs(untimedTasks) do
				dateToTasks[date][#dateToTasks[date]+1] = untimedTask
			end
			for _, timedTask in ipairs(timedTasks) do
				dateToTasks[date][#dateToTasks[date]+1] = timedTask
			end

			break

		end

	end

	hFile = io.open(sTaskListFile, "w")

	-- rewrite file for every date
	for _, date in ipairs(dateOrder) do
		hFile:write(date, "\n")
		for _, task in ipairs(dateToTasks[date]) do
			hFile:write(task, "\n")
		end
	end

	hFile:close()

end

function CheckDate()

	local hFile = io.open(sTaskListFile, "r")
	local lines = {}
	local restOfFile
	local noDates = true

	-- read through task list
	for line in hFile:lines() do

		-- remember recurring tasks
		if string.sub(line,-2,-1) == "|R" then
			lines[#lines+1] = line
		end

		-- find current date (header)
		if line == GetCurrentDate() then
			restOfFile = hFile:read("*a")
		end

	end

	hFile:close()

	-- write current date (header)
	hFile = io.open(sTaskListFile, "w")
	hFile:write(GetCurrentDate(), "\n")

	-- write recurring tasks
	for i, line in ipairs(lines) do
		hFile:write(line, "\n")
	end

	-- write rest of file
	if restOfFile then hFile:write(restOfFile) end

	hFile:close()

end

function CheckLine(lineNumber)

	local hFile = io.open(sTaskListFile, "r")
	local lines = {}
	local restOfFile
	local lineCt = 1

	-- read file into table
	for line in hFile:lines() do
		lines[#lines + 1] = line
	end
	hFile:close()

	-- find line to be altered
	if lines[lineNumber] then

		local line = lines[lineNumber]
		if string.sub(line,1,1) ~= "+" then
			lines[lineNumber] = "+"..line
		else
			lines[lineNumber] = string.sub(line,2,string.len(line))
		end

	end

	hFile = io.open(sTaskListFile, "w")
	-- write back the file
	for i, line in ipairs(lines) do
	  hFile:write(line, "\n")
	end

	hFile:close()

	-- only sort after checking if it is enabled
	if sortToggle == "true" then SortTasks() end

end

function ResetAll()
	
	local hFile = io.open(sTaskListFile, "r")
	local lines = {}

	-- read through task list
	for line in hFile:lines() do
		-- do not delete recurring tasks
  		if string.sub(line,-2,-1) == "|R" then
	  		lines[#lines + 1] = line
	  	-- do not delete uncompleted tasks
	  	elseif string.sub(line,1,1) ~= "+" and string.sub(line,-2,-1) ~= "|R" then
	  		lines[#lines + 1] = line 
	  	end
  	end

	hFile:close()

	hFile = io.open(sTaskListFile, "w")

	for i, line in ipairs(lines) do
	  hFile:write(line, "\n")
	end

	hFile:close()

	SortTasks()

end

function AddTask(newline)

	-- read entire task list
	local hFile = io.open(sTaskListFile, "r")
	local lines = {}
	local nextHeader
	local inHeader = false

	-- find current date header
	for line in hFile:lines() do
		-- check if task is added to correct date
		if line == GetCurrentDate() then
			inHeader = true
		else
			-- add task to last item in the list of tasks
			if inHeader then
				if string.match(line, "^%d%d/%d%d/%d%d$") then
					-- save current line as it has not been saved
					nextHeader = line
					break
				end
			end
		end
		lines[#lines+1] = line
	end

	local restOfFile = hFile:read("*a")
	hFile:close()

	-- write task list back to itself till current header
	hFile = io.open(sTaskListFile, "w")
	
	for i, line in ipairs(lines) do
		hFile:write(line, "\n")
	end

	--write newline if not header
	if not string.match(newline, "^%d%d/%d%d/%d%d$") then
		hFile:write(newline, "\n")
	end

	--write rest of the file
	if nextHeader then hFile:write(nextHeader, "\n") end
	hFile:write(restOfFile)

	hFile:close()

	SortTasks()

end