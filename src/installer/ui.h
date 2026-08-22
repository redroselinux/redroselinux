#pragma once

#include <sys/ioctl.h>

#define WELCOME_BANNER \
"\033[2J\033[H\033[91m" \
"\033[31m ███▄███ ▄▄▄▄▄             █\n" \
" ███████ █   ▀█  ▄▄▄    ▄▄▄█   ▄ ▄▄   ▄▄▄    ▄▄▄    ▄▄▄\n" \
"  ▀▀█▀▀  █▄▄▄▄▀ █▀  █  █▀ ▀█   █▀  ▀ █▀ ▀█  █   ▀  █▀  █ \n" \
"\033[32m ████\033[31m    █   ▀▄ █▀▀▀▀  █   █   █     █   █   ▀▀▀▄  █▀▀▀▀ \n" \
"\033[32m  ▀▀█\033[31m    █    █ ▀█▄▄▀  ▀█▄██   █     ▀█▄█▀  ▀▄▄▄▀  ▀█▄▄▀ \n" \
"\n\033[93m" \
" ▄        ▀                        \n" \
" █      ▄▄▄    ▄ ▄▄   ▄   ▄  ▄   ▄ \n" \
" █        █    █▀  █  █   █   █▄█  \n" \
" █        █    █   █  █   █   ▄█▄  \n" \
" █▄▄▄▄▄ ▄▄█▄▄  █   █  ▀▄▄▀█  ▄▀ ▀▄ \n" \
"                                   \033[92m\n" \
"                                                               \n" \
" ▄▄▄▄▄                  ▄           ▀▀█    ▀▀█                 \n" \
"   █    ▄ ▄▄    ▄▄▄   ▄▄█▄▄   ▄▄▄     █      █     ▄▄▄    ▄ ▄▄ \n" \
"   █    █▀  █  █   ▀    █    ▀   █    █      █    █▀  █   █▀  ▀\n" \
"   █    █   █   ▀▀▀▄    █    ▄▀▀▀█    █      █    █▀▀▀▀   █    \n" \
" ▄▄█▄▄  █   █  ▀▄▄▄▀    ▀▄▄  ▀▄▄▀█    ▀▄▄    ▀▄▄  ▀█▄▄▀   █\n\n\033[0m"
#define INSTALL_TO_HEADER \
"\033[2J\033[H\033[33m" \
" ▄▄▄▄▄                  ▄           ▀▀█    ▀▀█       ▄          \n" \
"   █    ▄ ▄▄    ▄▄▄   ▄▄█▄▄   ▄▄▄     █      █     ▄▄█▄▄   ▄▄▄  \n" \
"   █    █▀  █  █   ▀    █    ▀   █    █      █       █    █▀ ▀█ \n" \
"   █    █   █   ▀▀▀▄    █    ▄▀▀▀█    █      █       █    █   █ \n" \
" ▄▄█▄▄  █   █  ▀▄▄▄▀    ▀▄▄  ▀▄▄▀█    ▀▄▄    ▀▄▄     ▀▄▄  ▀█▄█▀ \033[0m\n\n"
#define INSTALLED_BANNER \
"\033[2J\033[H\033[92m" \
" ▄▄▄▄▄                  ▄           ▀▀█    ▀▀█               █\n" \
"   █    ▄ ▄▄    ▄▄▄   ▄▄█▄▄   ▄▄▄     █      █     ▄▄▄    ▄▄▄█\n" \
"   █    █▀  █  █   ▀    █    ▀   █    █      █    █▀  █  █▀ ▀█\n" \
"   █    █   █   ▀▀▀▄    █    ▄▀▀▀█    █      █    █▀▀▀▀  █   █\n" \
" ▄▄█▄▄  █   █  ▀▄▄▄▀    ▀▄▄  ▀▄▄▀█    ▀▄▄    ▀▄▄  ▀█▄▄▀  ▀█▄██\033[0m\n"
#define INSTALLING_HEADER \
"\033[2J\033[H\033[91m\033[38;5;208m" \
" ▄▄▄▄▄                  ▄           ▀▀█    ▀▀█      ▀\n" \
"   █    ▄ ▄▄    ▄▄▄   ▄▄█▄▄   ▄▄▄     █      █    ▄▄▄    ▄ ▄▄    ▄▄▄▄\n" \
"   █    █▀  █  █   ▀    █    ▀   █    █      █      █    █▀  █  █▀ ▀█\n" \
"   █    █   █   ▀▀▀▄    █    ▄▀▀▀█    █      █      █    █   █  █   █\n" \
" ▄▄█▄▄  █   █  ▀▄▄▄▀    ▀▄▄  ▀▄▄▀█    ▀▄▄    ▀▄▄  ▄▄█▄▄  █   █  ▀█▄▀█\n" \
"                                                                 ▄  █\n" \
"                                                                  ▀▀\n\033[0m"
#define LOCALIZE \
"\033[2J\033[H\033[92m" \
" ▄                           ▀▀█      ▀                 \n" \
" █       ▄▄▄    ▄▄▄    ▄▄▄     █    ▄▄▄    ▄▄▄▄▄   ▄▄▄  \n" \
" █      █▀ ▀█  █▀  ▀  ▀   █    █      █       ▄▀  █▀  █ \n" \
" █      █   █  █      ▄▀▀▀█    █      █     ▄▀    █▀▀▀▀ \n" \
" █▄▄▄▄▄ ▀█▄█▀  ▀█▄▄▀  ▀▄▄▀█    ▀▄▄  ▄▄█▄▄  █▄▄▄▄  ▀█▄▄▀  \n\033[0m"
#define USER_SETUP_HEADER \
"\033[2J\033[H\033[94m" \
" ▄    ▄                                        ▄                 \n" \
" █    █  ▄▄▄    ▄▄▄    ▄ ▄▄     ▄▄▄    ▄▄▄   ▄▄█▄▄  ▄   ▄  ▄▄▄▄  \n" \
" █    █ █   ▀  █▀  █   █▀ ▀    █   ▀  █▀  █    █    █   █  █▀ ▀█ \n" \
" █    █  ▀▀▀▄  █▀▀▀▀   █        ▀▀▀▄  █▀▀▀▀    █    █   █  █   █ \n" \
" ▀▄▄▄▄▀ ▀▄▄▄▀  ▀█▄▄▀   █       ▀▄▄▄▀  ▀█▄▄▀    ▀▄▄  ▀▄▄▀█  ██▄█▀ \n" \
"                                                           █     \n" \
"                                                           ▀     \n\033[0m"
#define ADVANCED_HEADER \
"\033[2J\033[H\033[31m" \
"   ▄▄       █                                         █ \n" \
"   ██    ▄▄▄█  ▄   ▄   ▄▄▄   ▄ ▄▄    ▄▄▄    ▄▄▄    ▄▄▄█ \n" \
"  █  █  █▀ ▀█  ▀▄ ▄▀  ▀   █  █▀  █  █▀  ▀  █▀  █  █▀ ▀█ \n" \
"  █▄▄█  █   █   █▄█   ▄▀▀▀█  █   █  █      █▀▀▀▀  █   █ \n" \
" █    █ ▀█▄██    █    ▀▄▄▀█  █   █  ▀█▄▄▀  ▀█▄▄▀  ▀█▄██ \n\n\033[0m"

char* ask(char* prompt);
void print_welcome(const struct winsize* w);
void print_localize_header(const struct winsize* window);
void print_usersetup_header(const struct winsize* window);
void print_advanced_header(const struct winsize* window);
void print_inst_to_header(const struct winsize* window);
void print_installing(const struct winsize* window);
void print_installed(const struct winsize* window);
char* ask_with_default(char* prompt, char* default_input);
char* password_ask(char* prompt, char* default_input);
