--// Dependencies

local tutility = require(script.Parent.tutility)

--// Connection

local ConnectionPrototype = {}
local ConnectionMetatable = { __index = ConnectionPrototype }

--// Public

export type ConnectionType = typeof(setmetatable(
	{} :: {
		_callback: (...any) -> ...any,
		_references: { [number]: { [number]: ConnectionType } },
		_proxy: RBXScriptConnection?,
	},
	ConnectionMetatable
))

function ConnectionPrototype.disconnect(self: ConnectionType)
	tutility.deep_iterate(self._references, function(value: any, index: any, parent: { [any]: any })
		if value ~= self then
			return
		end

		if type(index) == "number" then
			table.remove(parent, index)
		else
			parent[index] = nil
		end
	end)

	if typeof(self._proxy) == "RBXScriptConnection" then
		self._proxy:Disconnect()
		self._proxy = nil
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

local function new(callback: (...any) -> ...any, ...: { [any]: any }): ConnectionType
	return setmetatable({
		_callback = callback,
		_references = { ... },
	}, ConnectionMetatable)
end

local function wrap(signal: RBXScriptSignal, callback: (...any) -> ...any, ...: { [any]: any })
	local wrapped_connection = new(callback, ...)

	wrapped_connection._proxy = signal:Connect(function(...: any)
		wrapped_connection:call(...)
	end)

	return wrapped_connection
end

local function is(object: any): boolean
	return type(object) == "table" and getmetatable(object) == ConnectionMetatable
end

--// Export

return table.freeze({
	new = new,
	wrap = wrap,

	is = is,
})
