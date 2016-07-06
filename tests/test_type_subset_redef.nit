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

# Actual testing is done in `test_type_subset_redef2`.

import kernel

class NonZero
	subset
	super Numeric

	fun int_inverse: Int do
		return (1 / self).to_i
	end
end

# If the supertype is specified in a "redef", a specialization of the subset is
# created if it not already exists.

redef class NonZero
	super Int

	redef fun int_inverse: Int do
		return super - 1
	end

	#alt3# fun something do return 0
	#alt4# redef fun abs do return super
end