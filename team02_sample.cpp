#include <windows.h>
#include <iostream>

int main() {
    std::cout << "Iniciando el malware simulado del equipo..." << std::endl;
    std::cout << "MAGIC: fcfm-team2-pac" << std::endl;
    std::cout << "Esperamos 2 segundos..." << std::endl;
    Sleep(2000); 

    std::cout << "Escribiendo archivo temporal..." << std::endl;
    HANDLE archivo = CreateFileA("C:\\temp\\log_fcfm.txt", GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    
    if (archivo != INVALID_HANDLE_VALUE) {
        DWORD bytesEscritos;
        const char* texto = "Payload de prueba:\n";
        WriteFile(archivo, texto, strlen(texto), &bytesEscritos, NULL);
        CloseHandle(archivo);
    } else {
        std::cout << "fallo al crear archivo temporal" << std::endl;
    }

    std::cout << "lanzando calc.exe" << std::endl;
    WinExec("calc.exe", SW_SHOW);

    return 0;
}