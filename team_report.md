# Informe Final

**Equipo:** 2 - FCFM  
**Integrantes:**

	José Miguel Castellanos Martínez
	
	Jonathan Emir Jacobo Martínez
	
	Brandon Yahir Flores Garcia
	
	Juan Carlos Fernández Flores
	
**Fecha:** 13 de abril de 2026  
**Binario analizado:** `team02_sample.exe`  

---

## 1. Resumen Ejecutivo

Se realizó un análisis forense completo de un binario benigno diseñado para simular comportamientos de malware. El binario, creado por el Equipo 2, ejecuta `calc.exe`, crea un archivo temporal en `C:\temp\log_fcfm.txt` con contenido de prueba, e imprime cadenas identificadoras como `MAGIC: fcfm-team2-pac`.

Se aplicaron técnicas de análisis estático, ingeniería inversa, patching, debugging dinámico, detección YARA y clasificación CAPA.

**Hallazgo principal:** 

El binario es fácilmente detectable mediante YARA debido a su cadena mágica única y la combinación de APIs sospechosas (`WinExec`, `CreateFileA`, `WriteFile`, `Sleep`). CAPA identificó correctamente las capacidades de ejecutar procesos, escribir archivos y pausar la ejecución.

---

## 2. Descripción del Binario Creado

| Propiedad | Valor |
|-----------|-------|
| **Nombre** | `team02_sample.exe` |
| **Compilador** | MSVC (cl.exe) |
| **Arquitectura** | amd64 (64 bits) |
| **SHA256** | `03983e66c1570b51ee197d0a3a05ee258fd28a1504a9b10116409168c525cd87` |

### Comportamiento original:

1. Imprime: `Iniciando el malware simulado del equipo...`
2. Imprime: `MAGIC: fcfm-team2-pac`
3. Imprime: `Esperamos 2 segundos...`
4. `Sleep(2000)` - Pausa de 2 segundos
5. `CreateFileA("C:\\temp\\log_fcfm.txt")` - Crea archivo
6. `WriteFile` - Escribe `Payload de prueba:\n`
7. `CloseHandle` - Cierra el archivo
8. `WinExec("calc.exe")` - Lanza calculadora

### Código fuente original:

```cpp
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
