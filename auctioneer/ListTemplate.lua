--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	List Frame Template
	
	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--]]

local MAX_COLUMNS = 6;

-------------------------------------------------------------------------------
-- Compare two rows
-------------------------------------------------------------------------------
local CurrentListFrame = nil;
function ListTemplate_CompareRows(row1, row2)
	frame = CurrentListFrame;
	for index in frame.sortOrder do
		local column = frame.sortOrder[index];
		local physicalColumn = frame.physicalColumns[column.columnIndex];
		local logicalColumn = physicalColumn.logicalColumn;
		local value1 = logicalColumn.valueFunc(row1);
		local value2 = logicalColumn.valueFunc(row2);
		if (value1 ~= value2) then
			if (column.sortAscending and logicalColumn.compareAscendingFunc) then
				return logicalColumn.compareAscendingFunc(row1, row2);
			elseif (not column.sortAscending and logicalColumn.compareDescendingFunc) then
				return logicalColumn.compareDescendingFunc(row1, row2);
			end
		end
	end
	return false;
end

-------------------------------------------------------------------------------
-- Initialize the list with the column information
-------------------------------------------------------------------------------
function ListTemplate_Initialize(frame, physicalColumns, logicalColumns)
	frame.lines = 19;
	frame.lineHeight = 16;
	frame.content = {};
	frame.physicalColumns = physicalColumns;
	frame.logicalColumns = logicalColumns;

	frame.sortOrder = {};
	for physicalColumnIndex = 1, MAX_COLUMNS do
		local button = getglobal(frame:GetName().."Column"..physicalColumnIndex.."Sort");
		local dropdown = getglobal(frame:GetName().."Column"..physicalColumnIndex.."DropDown");
		if (physicalColumnIndex <= table.getn(physicalColumns)) then
			local physicalColumn = physicalColumns[physicalColumnIndex];
			local logicalColumn = physicalColumn.logicalColumn
			local column = {};
			column.columnIndex = physicalColumnIndex;
			column.sortAscending = true;
			table.insert(frame.sortOrder, column);
			getglobal(button:GetName().."Arrow"):Hide();
			getglobal(button:GetName().."Text"):SetText(logicalColumn.title);
			button:Show();
			if (table.getn(physicalColumn.logicalColumns) > 1) then
				dropdown:Show();
			else
				dropdown:Hide();
			end
			ListTemplate_SetColumnWidth(frame, physicalColumnIndex, physicalColumn.width);
		else
			button:Hide();
			dropdown:Hide();
		end
	end
	getglobal(frame:GetName().."Column1SortArrow"):Show();
	getglobal(frame:GetName().."Column1SortArrow"):SetTexCoord(0, 0.5625, 0, 1.0);
end

-------------------------------------------------------------------------------
-- Initialize the list with the column information
-------------------------------------------------------------------------------
function ListTemplate_SetColumnWidth(frame, column, width)
	frame.physicalColumns[column].width = width;
	local button = getglobal(frame:GetName().."Column"..column.."Sort");
	button:SetWidth(width + 2);
	local dropdown = getglobal(frame:GetName().."Column"..column.."DropDown");
	UIDropDownMenu_SetWidth(width - 18, dropdown);
end

-------------------------------------------------------------------------------
-- Set the item to display.
-------------------------------------------------------------------------------
function ListTemplate_SetContent(frame, content)
	frame.content = content;

	-- Perform the sort.
	CurrentListFrame = frame;
	table.sort(frame.content, ListTemplate_CompareRows);
	CurrentListFrame = nil;

	-- Update the scroll pane.
	ListTemplateScrollFrame_Update(getglobal(frame:GetName().."ScrollFrame"));
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ListTemplate_SelectRow(frame, row)
	if (frame.selectedRow ~= row) then
		local scrollFrame = getglobal(frame:GetName().."ScrollFrame");
		local firstVisibleRow = FauxScrollFrame_GetOffset(scrollFrame) + 1;
		local lastVisibleRow = firstVisibleRow + frame.lines - 1;

		-- Deselect the previous row
		if (frame.selectedRow and firstVisibleRow <= frame.selectedRow and frame.selectedRow <= lastVisibleRow) then
			local line = frame.selectedRow - firstVisibleRow + 1;
			local item = getglobal(frame:GetName().."Item"..line);
			item:UnlockHighlight();
		end
	
		-- Update the selected item
		frame.selectedRow = row;

		-- Select the new row		
		if (frame.selectedRow and firstVisibleRow <= frame.selectedRow and frame.selectedRow <= lastVisibleRow) then
			local line = frame.selectedRow - firstVisibleRow + 1;
			local item = getglobal(frame:GetName().."Item"..line);
			item:LockHighlight();
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ListTemplate_Sort(frame, columnIndex)
	-- Update the SortColumn order
	if (frame.sortOrder[1].columnIndex == columnIndex) then
		frame.sortOrder[1].sortAscending = not frame.sortOrder[1].sortAscending;
	else
		getglobal(frame:GetName().."Column"..frame.sortOrder[1].columnIndex.."SortArrow"):Hide();
		for index in frame.sortOrder do
			if (frame.sortOrder[index].columnIndex == columnIndex) then
				local temp = frame.sortOrder[index];
				table.remove(frame.sortOrder, index);
				table.insert(frame.sortOrder, 1, temp);
				break;
			end
		end
		frame.sortOrder[1].sortAscending = true;
		getglobal(frame:GetName().."Column"..frame.sortOrder[1].columnIndex.."SortArrow"):Show();
	end
	
	-- Perform the sort.
	CurrentListFrame = frame;
	table.sort(frame.content, ListTemplate_CompareRows);
	CurrentListFrame = nil;

	-- Update the sort arrow.
	if (frame.sortOrder[1].sortAscending) then
		getglobal(frame:GetName().."Column"..frame.sortOrder[1].columnIndex.."SortArrow"):SetTexCoord(0, 0.5625, 0, 1.0);
	else
		getglobal(frame:GetName().."Column"..frame.sortOrder[1].columnIndex.."SortArrow"):SetTexCoord(0, 0.5625, 1.0, 0);
	end
	
	-- Update the scroll pane.
	ListTemplateScrollFrame_Update(getglobal(frame:GetName().."ScrollFrame"));
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ListTemplateScrollFrame_Update(frame)
	if (not frame) then frame = this end;
	local parent = frame:GetParent();
	local content = parent.content;
	FauxScrollFrame_Update(frame, table.getn(content), parent.lines, parent.lineHeight);
	for line = 1, parent.lines do
		local item = getglobal(parent:GetName().."Item"..line);
		local contentIndex = line + FauxScrollFrame_GetOffset(frame);
		if contentIndex <= table.getn(content) then
			for columnIndex in parent.physicalColumns do
				local physicalColumn = parent.physicalColumns[columnIndex];
				local logicalColumn = physicalColumn.logicalColumn;
				local value = logicalColumn.valueFunc(content[contentIndex]);
				local control = getglobal(parent:GetName().."Item"..line.."Column"..columnIndex);
				if (value) then
					if (logicalColumn.dataType == "Date" or logicalColumn.dataType == "Number" or logicalColumn.dataType == "String") then
						control:SetText(value);
						if (logicalColumn.colorFunc) then
							local color = logicalColumn.colorFunc(content[contentIndex]);
							control:SetTextColor(color.r, color.g, color.b);
						else
							control:SetTextColor(255, 255, 255);
						end
					elseif (logicalColumn.dataType == "Money") then
						local control = getglobal(parent:GetName().."Item"..line.."Column"..columnIndex);
						if (value >= 0) then
							MoneyFrame_Update(control:GetName(), value);
							SetMoneyFrameColor(control:GetName(), 255, 255, 255);
						else
							MoneyFrame_Update(control:GetName(), -value);
							SetMoneyFrameColor(control:GetName(), 255, 0, 0);
						end
					end
					control:Show();
				else
					control:Hide();
				end
				if (logicalColumn.alphaFunc) then
					local alpha = logicalColumn.alphaFunc(content[contentIndex]);
					control:SetAlpha(alpha);
				else
					control:SetAlpha(1.0);
				end
			end
			if (parent.selectedRow and parent.selectedRow == contentIndex) then
				item:LockHighlight();
			else
				item:UnlockHighlight();
			end
			item:Show();
		else
			item:Hide();
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ListTemplate_DropDown_OnLoad()
	getglobal(this:GetName().."Text"):Hide();
	UIDropDownMenu_Initialize(this, ListTemplate_DropDown_Initialize);
	UIDropDownMenu_SetSelectedID(this, 1);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ListTemplate_DropDown_Initialize()
	local dropdown = this:GetParent();
	local frame = dropdown:GetParent();
	if (frame.physicalColumns) then
		local physicalColumnIndex = dropdown:GetID();
		local physicalColumn = frame.physicalColumns[physicalColumnIndex];
		for index in physicalColumn.logicalColumns do
			local logicalColumn = physicalColumn.logicalColumns[index];
			local info = {};
			info.text = logicalColumn.title;
			info.func = ListTemplate_DropDownItem_OnClick;
			info.owner = dropdown;
			UIDropDownMenu_AddButton(info);
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function  ListTemplate_DropDownItem_OnClick()
	local logicalColumnIndex = this:GetID();
	local physicalColumnIndex = this.owner:GetID();
	local dropdown = this.owner;
	local frame = dropdown:GetParent();
	if (frame.physicalColumns[physicalColumnIndex].logicalColumn ~= frame.physicalColumns[physicalColumnIndex].logicalColumns[logicalColumnIndex]) then
		-- Change the physical column's logical column
		frame.physicalColumns[physicalColumnIndex].logicalColumn = frame.physicalColumns[physicalColumnIndex].logicalColumns[logicalColumnIndex];
		getglobal(frame:GetName().."Column"..physicalColumnIndex.."SortText"):SetText(frame.physicalColumns[physicalColumnIndex].logicalColumn.title);

		-- Sort the content based on the new logical column
		CurrentListFrame = frame;
		table.sort(frame.content, ListTemplate_CompareRows);
		CurrentListFrame = nil;

		-- Update the combo and scroll pane.
		UIDropDownMenu_SetSelectedID(dropdown, logicalColumnIndex);
		ListTemplateScrollFrame_Update(getglobal(frame:GetName().."ScrollFrame"));
	end
end


