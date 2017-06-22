--
-- Author: Your Name
-- Date: 2017-06-15 14:54:56
--
local c = cc or {}
c.Group = c.Group or {}


function c.Group:create(cks, cb, default)

	self._curSelectedIndex = default
	for i = 1, #cks do
		local ck = cks[i]
		ck:setSelected(false)
		ck:addEventListener(function(obj, eventType)
			
			if self._curSelectedIndex and cks[self._curSelectedIndex] and ck ~= cks[self._curSelectedIndex] then
				cks[self._curSelectedIndex]:setSelected(false)
			end

			self._curSelectedIndex = i

			ck:setSelected(true)

			if cb then
				cb(i)
			end
		end)
	end

	if self._curSelectedIndex and cks[self._curSelectedIndex] then
		cks[self._curSelectedIndex]:setSelected(true)
	end

	return self
end

function c.Group:getSelectedIndex()
	return self._curSelectedIndex
end