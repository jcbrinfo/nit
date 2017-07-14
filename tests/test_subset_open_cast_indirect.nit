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

# Ensure that the rapid type analysis scans methods it discovers after handling the open types.
#
# Note that we never cast to `Natural` explicitly. However, by calling
# `Array[Natural]::output_arg`, we indirectly cast `42` to `Natural`.

import core::kernel

redef class Int
	fun is_natural: Bool do
		var box = new IntBox(self)
		return box.is_natural
	end
end

class IntBox
	var inner: Int
	fun is_natural: Bool do return inner >= 0
end

subset Natural
	super Int
	isa do return is_natural
end

class Foo[E: Int]
	fun output_arg(x: E) do x.output
end

var foo: Foo[Int] = new Foo[Natural]
foo.output_arg(42)
#alt1# foo.output_arg(-1)
