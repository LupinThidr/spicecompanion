#include <linux/limits.h>
#include <unistd.h>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <vector>
#include <flutter/flutter_window_controller.h>

// Returns the path of the directory containing this executable, or an empty
// string if the directory cannot be found.
static std::string GetExecutableDirectory() {
    char buffer[PATH_MAX + 1];
    ssize_t length = readlink("/proc/self/exe", buffer, sizeof(buffer));
    if (length > PATH_MAX) {
        std::cerr << "Couldn't locate executable" << std::endl;
        return "";
    }
    std::string executable_path(buffer, length);
    size_t last_separator_position = executable_path.find_last_of('/');
    if (last_separator_position == std::string::npos) {
        std::cerr << "Unable to find parent directory of " << executable_path << std::endl;
        return "";
    }
    return executable_path.substr(0, last_separator_position);
}

int main(int argc, char **argv) {

    // get base directory
    std::string base_directory = GetExecutableDirectory();
    if (base_directory.empty())
        base_directory = ".";

    // get other directories
    std::string data_directory = base_directory + "/data";
    std::string assets_path = data_directory + "/flutter_assets";
    std::string icu_data_path = data_directory + "/icudtl.dat";

    // flutter engine args
    std::vector<std::string> arguments;
#ifdef NDEBUG
    arguments.push_back("--disable-dart-asserts");
#endif

    // start the engine
    flutter::FlutterWindowController flutter_controller(icu_data_path);
    if (!flutter_controller.CreateWindow(800, 600, "SpiceCompanion", assets_path, arguments))
        return EXIT_FAILURE;

    // run until the window is closed.
    flutter_controller.RunEventLoop();
    return EXIT_SUCCESS;
}
