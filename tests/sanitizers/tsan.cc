// Copyright (c) Joby Aviation 2022
// Original authors: Thulio Ferraz Assis (thulio@aspect.dev), Aspect.dev
//
// Copyright (c) Thulio Ferraz Assis 2024
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <pthread.h>
#include <stdio.h>
#include <string>
#include <map>

typedef std::map<std::string, std::string> map_t;

void *threadfunc(void *p)
{
    map_t &m = *(map_t *)p;
    m["foo"] = "bar";
    return 0;
}

int main()
{
    map_t m;
    pthread_t t;
    pthread_create(&t, 0, threadfunc, &m);
    printf("foo=%s\n", m["foo"].c_str());
    pthread_join(t, 0);
}
