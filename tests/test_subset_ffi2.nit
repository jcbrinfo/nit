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

import core::kernel

in "C header" `{
	typedef struct {
		long x;
		long y;
	} point_t;
`}

extern class Point `{ point_t * `}
	new(x, y: Int) `{
		point_t* self = malloc(sizeof(point_t));
		if (self == NULL) {
			PRINT_ERROR("`malloc` failed.\n");
			exit(EXIT_FAILURE);
		}
		self->x = x;
		self->y = y;
		return self;
	`}
end

subset NaturalPoint
	super Point
	isa `{
		return self->x >= 0 && self->y >= 0;
	`}

	fun manhattan_distance: Int `{
		return self->x + self->y;
	`}
end

(new Point(3, 4)).as(NaturalPoint).manhattan_distance.output
