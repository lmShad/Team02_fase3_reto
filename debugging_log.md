# Debugging dinámico con x64dbg
**Equipo:** 2
**Binario:** `team02_sample.exe`

## 1. Colocación de Breakpoint en función principal (main)
Para localizar el punto de entrada lógico del malware y evitar el código de inicialización del compilador, realizamos una búsqueda de referencias de cadenas (*Search for -> Current Module -> String references*). 

Identificamos la cadena `MAGIC: fcfm-team2-pac` y nos dirigimos a su dirección de memoria. En la primera instrucción de esa función, colocamos un **Breakpoint de Software (F2)** para detener la ejecución justo antes de que inicien las acciones del dropper.

<img width="867" height="631" alt="image1" src="https://github.com/user-attachments/assets/2ad4b6fa-7342-428e-8848-3c5f9b855794" />

**

## 2. Configuración de Watchpoint (Hardware Breakpoint)
Para monitorear el acceso a la carga útil (*payload*), localizamos la dirección de memoria donde se almacena el string `"Payload de prueba:\n"` en la sección `.rdata`. 

Hicimos clic derecho sobre el primer byte en la ventana del *Dump* y seleccionamos **Breakpoint -> Hardware, Access -> Byte**. Este "Watchpoint" nos permite identificar el momento exacto en que la función `WriteFile` intenta leer el buffer para escribirlo en el disco, deteniendo la ejecución automáticamente.

<img width="975" height="715" alt="image2" src="https://github.com/user-attachments/assets/d23c7729-a069-4d95-b986-b506f58dcd99" />

**

## 3. Ejecución Paso a Paso (Stepping)
Utilizamos la instrucción **Step Over (F8)** para recorrer el flujo del programa. Observamos el siguiente comportamiento secuencial:
1. **Llamada a Sleep:** El programa se detiene por 2000ms (0x7D0 en hexadecimal), simulando una técnica de evasión de sandboxes.
2. **Preparación de argumentos:** Vimos cómo se cargaban en los registros RCX y RDX las rutas de archivos y banderas antes de entrar a las APIs de Windows.
3. **Llamada a CreateFileA:** Instrucción `CALL <JMP.&CreateFileA>`.

<img width="975" height="705" alt="image3" src="https://github.com/user-attachments/assets/ed111527-a243-48ff-8207-39f3064eb787" />

**

## 4. Documentación de Cambios en Registros y Memoria
Durante el análisis, documentamos los siguientes cambios críticos en el estado de la CPU:

* **Registro RAX:** Tras la ejecución de `CreateFileA`, el registro RAX cambió de `0` a un valor de *Handle* (ej. `0x00000000000000A4`), indicando que el archivo `log_fcfm.txt` se creó exitosamente.
* **Registros de Argumentos (x64 calling convention):** Observamos cómo **RCX** recibía el puntero a la ruta del archivo y **RDX** la dirección del buffer del payload justo antes de la llamada a `WriteFile`.
* **Memoria (Stack):** Al ejecutar `F8` sobre las funciones de salida, vimos en la ventana de registros cómo los valores se tornaban de color **rojo**, señalando la modificación de los registros de propósito general tras el retorno de la API.

<img width="975" height="705" alt="image4" src="https://github.com/user-attachments/assets/99ef75d6-54ac-4fd1-97cc-a7747b023656" />

<img width="975" height="691" alt="image44" src="https://github.com/user-attachments/assets/0004f555-92b7-4b74-b791-5f28e8803700" />

**
