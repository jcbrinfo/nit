# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import core

interface A
	new(x: Int) do
		print("new A({x})")
		return new B(x)
	end
end

class B
	super A
	var x: Int
end

class S
	super A
	subset do return true
	new(x: Int) do
		print("new S({x})")
		var a = new A(x)
		assert a isa S #alt1#
		return a
	end
end

var a = new A(1)
var s = new S(2)