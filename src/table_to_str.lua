-- exports: table_to_str function

local table_to_str = nil

do -- BEGIN LIB BLOCK


-- glob refs
-- local type     = type
-- local rawequal = rawequal
-- local tostring = tostring

local E_TYPE_NIL     = 1
local E_TYPE_BOOLEAN = 2
local E_TYPE_NUMBER  = 3
local E_TYPE_STRING  = 4
local E_TYPE_TABLE   = 5


local valid_types = {
	["boolean"] = E_TYPE_BOOLEAN,
	["number"]  = E_TYPE_NUMBER,
	["string"]  = E_TYPE_STRING,
	["table"]   = E_TYPE_TABLE,
	["nil"]     = E_TYPE_NIL,
}
local S_TYPE_BOOLEAN_FALSE = "false"
local S_TYPE_BOOLEAN_TRUE  = "true"
local S_TYPE_NIL           = "nil"

local types_to_string = nil
local can_serialize_obj = function(obj)
	if obj then
		-- valid true types:
		-- boolean (true)
		-- number
		-- string
		-- table
		local xtype = valid_types[type(obj)]
		if xtype then
			return xtype
		else
			return false
		end
	else
		-- valid false types:
		-- nil
		-- boolean (false)
		if rawequal(obj, nil) then
			return E_TYPE_NIL
		elseif rawequal(obj, false) then
			return E_TYPE_BOOLEAN
		else
			return false
		end
	end
end

local serialize_trusted_obj = nil
do
	local valid_types = {
		["o"] = E_TYPE_BOOLEAN,
		["u"] = E_TYPE_NUMBER,
		["t"] = E_TYPE_STRING,
		["a"] = E_TYPE_TABLE,
		["i"] = E_TYPE_NIL,
	}
	serialize_obj = function(obj)
		if obj then
			local xtype = valid_types[type(obj):sub(2,3)]
			-- assert(type(obj) ~= "function")
			types_to_string[xtype](obj)
		elseif rawequal(obj, nil) then
			return S_TYPE_NIL
		elseif rawequal(obj, false) then
			return S_TYPE_BOOLEAN_FALSE
		else
			error()
		end
	end
end

local can_serialize_table = function(invalid_type, table_obj)
	-- TODO
end

local table_to_string = function(table_obj)
	local state = {}
	-- TODO
end

types_to_string = {
	-- type nil
	function()
		return S_TYPE_NIL
	end,
	-- type boolean
	function(obj)
		if obj then
			return S_TYPE_BOOLEAN_TRUE
		else
			return S_TYPE_BOOLEAN_FALSE
		end
	end,
	-- type number
	tostring,
	-- type string
	function(x)return x end,
	-- type table
	table_to_string,
}

table_to_str = function(obj, no_validate_tables)
	local xtype = can_serialize_obj(obj)
	if not xtype then
		return nil, "cannot serialize object of type: " .. type(obj)
	end
	local invalid_type = {}
	if xtype == E_TYPE_TABLE and not no_validate_tables and not can_serialize_table(invalid_type, obj) then
		return nil, "table contains " .. invalid_type.mode .. " of type " .. invalid_type.str_type .. " that cannot be serialized"
	end
	invalid_type = nil
	return types_to_string[xtype](obj)
end



end  -- END LIB BLOCK