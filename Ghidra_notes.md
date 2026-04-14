# Notas de Ingeniería Inversa 

**Equipo:** 2
**Binario analizado:** `team02_sample.exe`
**Herramienta:** Ghidra (CodeBrowser)

## 1. Localización de la Función Principal
**Objetivo:** Identificar el punto exacto donde empieza nuestro código, saltándonos toda la "basura" de inicialización (CRT Startup) que inyecta el compilador[cite: 61].

* **Punto de entrada inicial:** Comenzamos el análisis en la función genérica `entry`.
* **Proceso de aislamiento:** Fuimos bajando por el código de inicialización de C/C++  hasta encontrar la subrutina que recibe los parámetros clásicos del sistema (`argc`, `argv`, `envp`).
* **Resolución:** En este punto, los símbolos del desensamblador ya habían hecho su trabajo y Ghidra reconoció automáticamente esta función con la firma `int __cdecl main(int _Argc, char **_Argv, char **_Env)`. Esto nos confirma que llegamos al código real del malware simulado.





<img width="1707" height="822" alt="Captura de pantalla 2026-04-13 211833" src="https://github.com/user-attachments/assets/e5de9959-c95b-4d0e-9cd4-b4e81fa4d127" />



## 2. Reconstrucción de Variables 
**Objetivo:** Limpiar el código desensamblado dándole nombres descriptivos a las variables locales que Ghidra detectó de forma genérica[cite: 62].

Al revisar el pseudocódigo en `main`, vimos que Ghidra asignó nombres como `local_10` a las variables en el stack. Haciendo un análisis dinámico mental basado en las APIs de Windows, reconstruimos lo siguiente:

* `local_10` (Tipo: `HANDLE`): La renombramos a `hFile`. Es la variable que guarda el puntero que devuelve `CreateFileA`.
* `local_1c` (Tipo: `DWORD`): La renombramos a `bytesWritten`. Es el parámetro que se pasa por referencia a `WriteFile` para confirmar cuántos bytes se escribieron realmente.

<img width="1699" height="462" alt="Captura de pantalla 2026-04-13 212607" src="https://github.com/user-attachments/assets/991d91c5-1c0e-4e38-80f9-53e4d9de8fd1" />


## 3. Análisis del Flujo de Ejecución
**Objetivo:** Documentar paso a paso qué hace el malware

Revisando el código en C ya limpio, el flujo de ataque es una secuencia bastante lineal:

1. **Señuelos visuales:** Hace varias llamadas a `std::cout` para imprimir cadenas inofensivas en la consola.
2. **Evasión básica:** Ejecuta un `Sleep` de 2000 ms, una técnica clásica para tratar de evadir sandboxes o análisis dinámicos rápidos.
3. **Dropping (Persistencia):** Intenta crear un archivo físico en la ruta `C:\temp\log_fcfm.txt`.
4. **Bifurcación Condicional (El punto clave):** Hace un `if` para validar si el `HANDLE` que devolvió el sistema es válido (`!= INVALID_HANDLE_VALUE`). 
   * **True:** Si es válido, inyecta el payload ("Payload de prueba:\n") en el archivo de texto.
   * **False:** Si falla, simplemente imprime un error en consola.
5. **Impacto:** Lanza la calculadora de Windows para hacer evidente la ejecución.

## 4. Identificación de Llamadas a API Relevantes
Aquí desglosamos las funciones críticas de `KERNEL32.dll` que usa el binario, junto con los argumentos *hardcodeados* que logramos extraer directamente del desensamblador:

| API de Windows | Argumentos Críticos Identificados | Propósito en el Binario |
| :--- | :--- | :--- |
| `Sleep` | `dwMilliseconds = 2000` (0x7D0) | Pausar la ejecución temporalmente para tratar de evadir análisis dinámicos (sandboxes). |
| `CreateFileA` | `lpFileName = "C:\\temp\\log_fcfm.txt"`, `dwCreationDisposition = 2` (CREATE_ALWAYS) | Preparar la ruta para dropear el archivo temporal (sobrescribe si ya hay uno). |
| `WriteFile` | `lpBuffer = "Payload de prueba:\n"`, `nNumberOfBytesToWrite = 19` | Inyectar el texto en el archivo. |
| `WinExec` | `lpCmdLine = "calc.exe"`, `uCmdShow = 5` (SW_SHOW) | Levantar el proceso de la calculadora de forma visible para el usuario. |

**Conclusión de la Fase:**
El análisis en Ghidra confirma lo que vimos en el análisis estático. Todo el comportamiento depende de la instrucción condicional que evalúa la creación del archivo (`if hFile != INVALID_HANDLE_VALUE`). Esa condición es el eslabón más débil del código, por lo que será nuestro objetivo principal para *bypassear* la escritura del payload en la siguiente fase de Patching.
