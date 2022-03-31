#include <iostream>
#include <fstream>

int main()
{
    std::ifstream names("examples/hello_world_cpp/names.txt");
    if (!names.is_open())
    {
        return 1;
    }
    for (std::string name; std::getline(names, name);)
    {
        std::cout << "Hello " << name << "!" << std::endl;
    }

    names.close();

    return 0;
}
