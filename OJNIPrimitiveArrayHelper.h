/*
 * Copyright 2016 Alexander Shitikov
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#ifndef OJNIPrimitiveArrayHelper_h
#define OJNIPrimitiveArrayHelper_h

#define CONCAT3_NAMES_(str1, str2, str3) str1##str2##str3
#define CONCAT2_NAMES_(str1, str2) str1##str2
#define CONCAT3_NAMES(str1, str2, str3) CONCAT3_NAMES_(str1, str2, str3)
#define CONCAT2_NAMES(str1, str2) CONCAT2_NAMES_(str1, str2)

#define NSNUMBER_VALUE(number, ptype) [number CONCAT2_NAMES(ptype, Value)]

#endif /* OJNIPrimitiveArrayHelper_h */
