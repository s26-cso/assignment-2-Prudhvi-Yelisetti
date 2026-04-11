#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main(){
    int num1, num2;
    char op[10];

    while (scanf("%5s %d %d", op, &num1, &num2) == 3){
        char lib[20];
        snprintf(lib, sizeof(lib), "./lib%s.so", op);

        void *module = dlopen(lib, RTLD_LAZY);

        if (module) {
            int (*operation)(int, int);
            operation = (int (*)(int, int)) dlsym(module, op);

            if (operation){
                int result = operation(num1, num2);
                printf("%d\n", result);
            }

            dlclose(module);
        }
    }

    return 0;
}