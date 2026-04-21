#include <stdio.h>

int main() {
    fputs(
        "\033[2J\033[H \e[91m____          _                      _     _                  \n"
        "|  _ \\ ___  __| |_ __ ___  ___  ___  | |   (_)_ __  _   ___  __\n"
        "| |_) / _ \\/ _` | '__/ _ \\/ __|/ _ \\ | |   | | '_ \\| | | \\ \\/ /\n"
        "|  _ <  __/ (_| | | | (_) \\__ \\  __/ | |___| | | | | |_| |>  < \n"
        "|_| \\_\\___|\\__,_|_|  \\___/|___/\\___| |_____|_|_| |_|\\__,_/_/\\_\\\n"
        "\e[92mWelcome!\e[0m\n\n",
        stdout
    );
    fflush(stdout);
    fputs("\e[97mWe wish you will enjoy Redrose just as much as we enjoy making it!\n\n", stdout);
    fputs("On the technical side:\e[0m\n     \e[94m-\e[0m Redrose uses the \e[40mrunit\e[0m init system\n     \e[94m-\e[0m To install packages, use our tool \e[40mcar\e[0m\n\n", stdout);
    fputs("\e[97mIf you wish to contribute:\e[0m\n     \e[94m-\e[0m All of our code is open\e[94m-\e[0msource.\n     \e[94m-\e[0m Docs: https://redroselinux.miraheze.org\n     \e[94m-\e[0m Github: https://github.com/redroselinux\n\n(press enter)", stdout);
    getchar();
    fputs(
        "\033[2J\033[H \e[91m____          _                      _     _                  \n"
        "|  _ \\ ___  __| |_ __ ___  ___  ___  | |   (_)_ __  _   ___  __\n"
        "| |_) / _ \\/ _` | '__/ _ \\/ __|/ _ \\ | |   | | '_ \\| | | \\ \\/ /\n"
        "|  _ <  __/ (_| | | | (_) \\__ \\  __/ | |___| | | | | |_| |>\e[35mww\e[0m\e[91m< \n"
        "|_| \\_\\___|\\__,_|_|  \\___/|___/\\___| |_____|_|_| |_|\\__,_/_/\\_\\\n"
        "\e[92mSome basic tool usage!\e[0m\n\n",
        stdout
    );
    fflush(stdout);
    fputs("\e[97mBasic usage of car:\n     \e[94m-\e[0m car install <package>\n     \e[94m-\e[0m car delete <package>\n     \e[94m-\e[0m car listup <- \e[32mequivalent of apt update\e[0m\n     \e[94m-\e[0m car update <- \e[32mequivalent of apt update && upgrade\e[0m\n\n(press enter)", stdout);
    getchar();
}
