#  Patching Report

## 1. Especificaciones Técnicas
* **Arquitectura:** x86_64 (Windows PE)
* **Herramientas:** Radare2, Cutter
* **Objetivo:** Subvertir la validación de archivos temporales para evadir el bloqueo de ejecución.

## 2. Análisis de Funciones y Desensamblado
Para iniciar el proceso de *patching*, se realizaron tareas de reconocimiento del binario utilizando la suite **Radare2**.

### A. Análisis General (`aaa`)
Se ejecutó el comando para realizar un análisis de intensidad completa (*Analyze all*), permitiendo la identificación de símbolos, funciones y referencias cruzadas.

<img width="780" height="139" alt="Imagen1" src="https://github.com/user-attachments/assets/d4a7ad2e-38a3-47e2-8bad-0dc0bba034fc" />

### B. Listado de Funciones (`afl`)
Se identificaron los puntos críticos de entrada. Se localizó la función `sym.main` como el objetivo primordial para el análisis de la lógica de control.
* **Entry Point:** `0x140001020`

<img width="596" height="195" alt="Imagen2" src="https://github.com/user-attachments/assets/e346d1b1-5996-4cf4-9d4c-9bbc55e8f79d" />

### C. Desensamblado de Función (`pdf`)
A través de la inspección del código ensamblador en la función principal, se rastreó el flujo de control para localizar el punto de fallo intencional.

<img width="595" height="167" alt="Imagen3" src="https://github.com/user-attachments/assets/5f64b859-5753-4b40-8ca5-8c59b884ffd7" />

---

## 3. Localización de la Instrucción Condicional
Se identificó un punto crítico donde el flujo depende del resultado de la operación `CreateFileA`. El programa utiliza este resultado para decidir si continúa o termina la ejecución.

* **Dirección:** `0x140001591`
* **Instrucción Original:** `je 0x1400015e3` (Jump if Equal)
* **Análisis:** Esta condicional provoca un salto a la rutina de error si la comparación en `0x14000158c` resulta verdadera (indicando que el archivo no pudo crearse o validarse).

<img width="780" height="396" alt="Imagen4" src="https://github.com/user-attachments/assets/7e79e0c8-3be1-4f34-900c-ec1624a5d5db" />

---

## 4. Modificación del Binario (Patching en Cutter)
Utilizando la interfaz de **Cutter**, se procedió a invertir la lógica del programa para forzar la ejecución del payload independientemente del resultado de la validación.

### Comparativa del Patch
| Atributo | Estado Original | Estado Parcheado |
| :--- | :--- | :--- |
| **Instrucción** | `je` (Jump if Equal) | `jne` (Jump if Not Equal) |
| **Opcodes** | `74 50` | `75 50` |
| **Dirección** | `0x140001591` | `0x140001591` |

<img width="411" height="213" alt="Imagen5" src="https://github.com/user-attachments/assets/5783f020-7a44-45c3-a20a-dfd2e0e2f767" />
<img width="432" height="220" alt="Imagen6" src="https://github.com/user-attachments/assets/d5971294-ff00-45fd-b0c7-e40222db032f" />

> **Nota técnica:** Se seleccionó la opción *"Rellenar el resto de los bytes con códigos de operación NOP"* (`0x90`). Aunque en este caso específico el tamaño de la instrucción no cambió, esta es una medida de seguridad para prevenir la corrupción de instrucciones adyacentes si se realizaran saltos de mayor longitud.

<img width="512" height="107" alt="Imagen7" src="https://github.com/user-attachments/assets/bdaaa708-37e9-4f26-a2b5-8036e6aed42a" />

---

## 5. Comparación de Comportamiento 
El *patching* permitió evadir la restricción lógica original del binario analizado.

* **Comportamiento Original:** El programa detectaba una falla en la interacción con el sistema de archivos y terminaba el proceso.
* **Comportamiento Parcheado:** Al invertir la condicional, el programa evade el bloqueo lógico, continúa su flujo y ejecuta acciones adicionales (en este caso, el lanzamiento de `calc.exe` como prueba de ejecución de código).

<img width="713" height="402" alt="Imagen8" src="https://github.com/user-attachments/assets/400d0d9b-8b49-4e91-9452-88c40cd4cb95" />


