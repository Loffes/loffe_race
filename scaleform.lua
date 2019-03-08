--https://scaleform.devtesting.pizza/

Scaleform = { }


local function scaleform_is_valid(scaleform)
	if scaleform == 0 then
		Citizen.Trace('Scaleform: invalid scaleform '..tostring(scaleform))
		return false
	end

	return true
end


local function scaleform_has_loaded(scaleform)
	if not HasScaleformMovieLoaded(scaleform) then
		Citizen.Trace('Scaleform: using not loaded scaleform '..tostring(scaleform))
		return false
	end

	return true
end


local function scaleform_is_int(number)
	return type(number) == "number" and not string.find(tostring(number), '%.')
end


function Scaleform.Request(id)
	if type(id) ~= "string" then
		Citizen.Trace('Scaleform: unable to request '..tostring(id))
		return nil
	end

	local result = RequestScaleformMovie(id)

	while not HasScaleformMovieLoaded(result) do 
		Citizen.Wait(0) 
	end

	return result
end


function Scaleform.Delete(scaleform)
	if not scaleform_is_valid(scaleform) then return end
	if not scaleform_has_loaded(scaleform) then return end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end


function Scaleform.Call(scaleform, func, ...)
	if not scaleform_is_valid(scaleform) then return end

	if type(func) ~= "string" then
		Citizen.Trace('Scaleform: unable to call '..tostring(func)..' func')
		return
	end

	PushScaleformMovieFunction(scaleform, func)

	local params = { ... }

	for _, param in ipairs(params) do
		local paramType = type(param)
		if paramType == 'string' then
			PushScaleformMovieFunctionParameterString(param)
		elseif paramType == 'number' then
			if scaleform_is_int(param) then
				PushScaleformMovieFunctionParameterInt(param)
			else
				PushScaleformMovieFunctionParameterFloat(param)
			end
		elseif paramType == 'boolean' then
			PushScaleformMovieFunctionParameterBool(param)
		elseif paramType == 'function' then
			param()
		else
			Citizen.Trace('Scaleform: invalid parameter type ['..tostring(paramType)..'] for scaleform '..tostring(scaleform))
			return
		end
	end

	PopScaleformMovieFunctionVoid()
end


function Scaleform.Render(scaleform, x, y, w, h, r, g, b, a)
	if not scaleform_is_valid(scaleform) then return end
	DrawScaleformMovie(scaleform, x, y, w, h, r or 255, g or 255, b or 255, a or 255)
end


function Scaleform.RenderFullscreen(scaleform, r, g, b, a)
	if not scaleform_is_valid(scaleform) then return end
	DrawScaleformMovieFullscreen(scaleform, r or 255, g or 255, b or 255, a or 255)
end