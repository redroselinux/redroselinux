#include <stdio.h>

int main() {
    fputs(
        "\033[2J\033[H ____          _                      _     _                  \n"
        "|  _ \\ ___  __| |_ __ ___  ___  ___  | |   (_)_ __  _   ___  __\n"
        "| |_) / _ \\/ _` | '__/ _ \\/ __|/ _ \\ | |   | | '_ \\| | | \\ \\/ /\n"
        "|  _ <  __/ (_| | | | (_) \\__ \\  __/ | |___| | | | | |_| |>  < \n"
        "|_| \\_\\___|\\__,_|_|  \\___/|___/\\___| |_____|_|_| |_|\\__,_/_/\\_\\\n"
        "\e[92mWelcome!\e[0m\n\n",
        stdout
    );
    fflush(stdout);
    fputs("We wish you will enjoy Redrose just as much as we enjoy making it!\n\n", stdout);
    fputs("On the technical side:\n     - Redrose uses the \e[40mrunit\e[0m init system\n     - To install packages, use our tool \e[40mcar\e[0m\n\n", stdout);
    fputs("If you wish to contribute:\n     - All of our code is open-source.\n     - Docs: https://redroselinux.miraheze.org\n     - Github: https://github.com/redroselinux\n\n(press enter)", stdout);
    getchar();
    fputs(
        "\033[2J\033[H ____          _                      _     _                  \n"
        "|  _ \\ ___  __| |_ __ ___  ___  ___  | |   (_)_ __  _   ___  __\n"
        "| |_) / _ \\/ _` | '__/ _ \\/ __|/ _ \\ | |   | | '_ \\| | | \\ \\/ /\n"
        "|  _ <  __/ (_| | | | (_) \\__ \\  __/ | |___| | | | | |_| |>\e[35mww\e[0m< \n"
        "|_| \\_\\___|\\__,_|_|  \\___/|___/\\___| |_____|_|_| |_|\\__,_/_/\\_\\\n"
        "\e[92mSome basic tool usage!\e[0m\n\n",
        stdout
    );
    fflush(stdout);
    fputs("Basic usage of \e[40mcar\e[0m:\n     - car install <package>\n     - car delete <package>\n     - car listup <- \e[32mequivalent of apt update\e[0m\n     - car update <- \e[32mequivalent of apt update && upgrade\e[0m\n\n(press enter)", stdout);
    getchar();
}
