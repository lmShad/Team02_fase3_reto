# Notas de Ingeniería Inversa 

**Equipo:** 2
**Binario analizado:** `team02_sample.exe`
**Herramienta:** Ghidra (CodeBrowser)

## 1. Localización de la Función Principal
**Objetivo:** Identificar el punto exacto donde empieza nuestro código, saltándonos toda la "basura" de inicialización (CRT Startup) que inyecta el compilador.

* **Punto de entrada inicial:** Comenzamos el análisis en la función genérica `entry`.
* **Proceso de aislamiento:** Fuimos bajando por el código de inicialización de C/C++  hasta encontrar la subrutina que recibe los parámetros clásicos del sistema (`argc`, `argv`, `envp`).
* **Resolución:** En este punto, los símbolos del desensamblador ya habían hecho su trabajo y Ghidra reconoció automáticamente esta función con la firma `int __cdecl main(int _Argc, char **_Argv, char **_Env)`. Esto nos confirma que llegamos al código real del malware simulado.





<img width="1707" height="822" alt="Captura de pantalla 2026-04-13 211833" src="https://github.com/user-attachments/assets/e5de9959-c95b-4d0e-9cd4-b4e81fa4d127" />



##  2. Reconstrucción de Estructura de Datos (Data Type Manager)
**Objetivo:** Agrupar variables relacionadas en memoria para demostrar el dominio de la abstracción de datos y mejorar la semántica del código.

Siguiendo los requisitos de la Fase 3, se realizó una reconstrucción lógica mediante la creación de un tipo de dato compuesto en el **Data Type Manager**. Esta técnica permite organizar los offsets de la pila como una entidad única de control.

* **Nombre de la estructura:** `PayloadConfig`
  <img width="1496" height="664" alt="Captura de pantalla 2026-04-13 223402" src="https://github.com/user-attachments/assets/bf2fbfe4-064e-402e-8115-c6e2ff5e6f42" />

* **Campos definidos:**
  * `HANDLE hFile`: Manejador para la persistencia del archivo.
  * `DWORD bytesWritten`: Contador de control para la inyección del payload.

Se utilizó la función **Retype Variable** sobre la variable `hFile` en el Stack Frame para aplicar esta estructura, logrando un pseudocódigo mucho más limpio y profesional.

<img width="260" height="135" alt="Captura de pantalla 2026-04-13 224438" src="https://github.com/user-attachments/assets/b1b365ae-4d7a-434f-8dd2-4278634c93f1" />



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
