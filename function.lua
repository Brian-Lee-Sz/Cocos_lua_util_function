function string.startsWith(str, chars)
	return chars == '' or string.sub(str, 1, string.len(chars)) == chars
end

function string.endWith(str, chars)
	local a = string.sub(str, string.len(str) - string.len(chars) + 1, string.len(str))
	return chars == '' or a == chars
end

--缩短金币显示文字
function string.sortMoney(money, isImgText, isCapital, floatNum)
	local floatNum =(floatNum or 2) - 1
	local output = ""
	local unit = ""
	local integer = ""
	local point = ""
	local float = ""
	local temp_float = ""
	local input = money and tostring(money) or ""
	local input_len = string.len(input)
	if input_len >= 10 then
		unit = isImgText and "<" or(isCapital and "B" or "b")
		integer = string.sub(input, 1, input_len - 9)
		local end_index = floatNum > 8 and input_len or input_len - 8 + floatNum
		temp_float = string.sub(input, input_len - 8, end_index)
	elseif input_len >= 7 then
		unit = isImgText and ";" or(isCapital and "M" or "m")
		integer = string.sub(input, 1, input_len - 6)
		local end_index = floatNum > 5 and input_len or input_len - 5 + floatNum
		temp_float = string.sub(input, input_len - 5, end_index)
	elseif input_len >= 4 then
		unit = isImgText and ":" or(isCapital and "K" or "k")
		integer = string.sub(input, 1, input_len - 3)
		local end_index = floatNum > 2 and input_len or input_len - 2 + floatNum
		temp_float = string.sub(input, input_len - 2, end_index)
	else
		integer = input
	end
	if(tonumber(temp_float) or 0) > 0 then
		point = "."
		local index = 0
		for i = 1, string.len(temp_float) do
			if string.byte(temp_float, i) ~= 48 then
				index = i
			end
		end
		float = index > 0 and string.sub(temp_float, 1, index) or float
	end
	return string.format("%s%s%s%s", integer, point, float, unit)
end

--字符分行
function string.wrapString(str, limmit)
	if not str then
		return
	end
	local limmit = limmit or 46
	local len = string.len(str)
	if len <= limmit then
		return str
	end
	local left = 1
	local arr = {0, 192, 224, 240, 248, 252} --0,192,224,240,248,256
	local cnt = 0
	local last_left = 1
	local output = ""
	local o_t
	while left <= len do
		local tmp = string.byte(str, left)
		local i = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left + i
				break
			end
			i = i - 1
		end
		cnt = cnt + i
		o_t = string.sub(str, last_left, left - 1)
		if cnt >= limmit then
			output = string.format("%s%s%s", output, o_t, left < len and "\n" or "")
			cnt = 0
			last_left = left
			o_t = nil
		end
	end
	if o_t then
		output = string.format("%s%s", output, o_t)
	end
	return output
end

--缩进字符串
function string.sortString(str, limmit)
	if not str then
		return ""
	end
	local limmit = limmit or 9
	local len = string.len(str)
	if len <= limmit then
		return str
	end
	local left = 1
	local arr = {0, 192, 224, 240, 248, 252} --0,192,224,240,248,256
	local cnt = 0
	local output = ""
	local o_t = ""
	while left <= len do
		local tmp = string.byte(str, left)
		local i = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left + i
				break
			end
			i = i - 1
		end
		cnt = cnt + i
		o_t = string.sub(str, 1, left - 1)
		if cnt >= limmit then
			output = string.format("%s%s%s", output, o_t, "...")
			return output
		end
	end
end

--判断真实显示值
local IsVisibleRecursively
IsVisibleRecursively = function(node)
	local isVisible = node:isVisible()
	if not isVisible then
		return false
	end
	local parent = node:getParent()
	if parent then
		return IsVisibleRecursively(parent)
	end
	return true
end

function SceneBase:registertTouchEvent(target)
	if target then
		local touchEventListener = cc.EventListenerTouchOneByOne:create()
		touchEventListener:setSwallowTouches(true)
		local this = self
		local onTouchEventBegan = function(touch, event)
			local size = event:getCurrentTarget():getContentSize()
			local rect = cc.rect(0, 0, size.width, size.height)
			local pos = event:getCurrentTarget():convertToNodeSpace(touch:getLocation())
			if cc.rectContainsPoint(rect, pos) and IsVisibleRecursively(event:getCurrentTarget()) then
				if this.onTouchEventBegan then return this:onTouchEventBegan(touch, event) end
			end
		end
		local onTouchEventMove = function(touch, event)
			if this.onTouchEventMove then this:onTouchEventMove(touch, event) end
		end
		local onTouchEventEnd = function(touch, event)
			if this.onTouchEventEnd then this:onTouchEventEnd(touch, event) end
		end
		touchEventListener:registerScriptHandler(onTouchEventBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		touchEventListener:registerScriptHandler(onTouchEventMove, cc.Handler.EVENT_TOUCH_MOVED)
		touchEventListener:registerScriptHandler(onTouchEventEnd, cc.Handler.EVENT_TOUCH_ENDED)
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(touchEventListener:clone(), target)
	end
end
