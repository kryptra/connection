--// Connection

local ConnectionPrototype = {}
local ConnectionMetatable = { __index = ConnectionPrototype }

--// Public

export type ConnectionType = typeof(setmetatable(
	{} :: {
		_callback: (...any) -> ...any,
		_references: { [number]: { [any]: ConnectionType } },
	},
	ConnectionMetatable
))

function ConnectionPrototype.disconnect(self: ConnectionType)
	for _: number, tbl: { [any]: ConnectionType } in pairs(self._references) do
		for index: any, value: ConnectionType in pairs(tbl) do
			if not self:is(value) or value ~= self then
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

function ConnectionPrototype.call(self: ConnectionType, ...: any): ...any
	if not self or not self._callback then
		return
	end

	return self._callback(...)
end

function ConnectionPrototype.is(_: ConnectionType, object: any): boolean
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
