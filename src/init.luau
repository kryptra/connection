--// Connection

local ConnectionPrototype = {}
local ConnectionMetatable = {
	__index = ConnectionPrototype,
	__call = function(self: ConnectionType, ...: any): ...any
		if not self._callback or self._callback and type(self._callback) ~= "function" then
			return
		end

		return self._callback(...)
	end,
}

--// Public

export type ConnectionType = typeof(setmetatable(
	{} :: {
		_callback: (...any) -> ...any,
		_references: { [number]: { [any]: ConnectionType } },
	},
	ConnectionMetatable
))

function ConnectionPrototype.Disconnect(self: ConnectionType)
	for _: number, tbl: { [any]: ConnectionType } in pairs(self._references) do
		for index: any, value: ConnectionType in pairs(tbl) do
			if not self:__is(value) or value ~= self then
				continue
			end

			if type(index) == "number" then
				table.remove(tbl, index)
			else
				tbl[index] = nil
			end
		end
	end

	setmetatable(self :: any, nil)

	table.clear(self :: any)
	table.freeze(self :: any)
end

function ConnectionPrototype.__is(_: ConnectionType, object: any): boolean
	if type(object) == "table" then
		return getmetatable(object) == ConnectionMetatable
	end

	return false
end

local function new(callback: (...any) -> ...any, ...: { [any]: any }): ConnectionType
	return setmetatable({
		_callback = callback,
		_references = { ... },
	}, ConnectionMetatable)
end

--// Export

return table.freeze({
	new = new,
})
