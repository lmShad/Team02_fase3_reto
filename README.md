#  Reto Fase 3: Análisis de Malware Simulado (Equipo 2)

Bienvenidos al repositorio del **Equipo 2** para la Fase 3 del reto de la materia de Programacion Avanzada para Ciberseguridad  (FCFM, UANL). 

Este repositorio contiene un binario de carácter **estrictamente educativo**, diseñado específicamente para simular el comportamiento de un "Dropper" básico, con el único fin de ser analizado utilizando técnicas de ingeniería inversa estática y dinámica.

>  **Aviso de Seguridad:** El archivo `team02_sample.exe` contenido en este repositorio **no es un malware real**. Su payload inyecta texto inofensivo en un archivo temporal. Sin embargo, debido a las técnicas de evasión simuladas y llamadas a la API de Windows, puede ser detectado por herramientas de seguridad (antivirus). **Se recomienda su análisis exclusivo en entornos controlados (Máquinas Virtuales).**

---

##  Estructura del Proyecto y Asignación de Tareas

A continuación, se detalla la aportación de cada miembro del equipo y el archivo correspondiente a su tarea:

| Tarea | Analista Encargado | Archivo Entregable | Descripción Breve |
| :--- | :--- | :--- | :--- |
| **1. Desarrollo del Malware** | Jonathan Jacobo | `team02_sample.cpp` / `.exe` | Código fuente en C++ y binario ejecutable (Dropper simulado). |
| **2. Análisis Estático Base** | Jonathan Jacobo | `static_overview.md` | Identificación de strings e imports usando `rabin2`. |
| **3. Análisis con Ghidra** | Juan Fernandez | `ghidra_notes.md` | Reconstrucción de la estructura de memoria y de compilación. |
| **4. Patching con Radare2/Cutter**| Brandon Flores | `patch_report.md` / `_patched.exe` | Alteración de los saltos condicionales (JMP/JNE) para evadir el payload. |
| **5. Análisis Dinámico (x64dbg)**| Brandon Flores | `debugging_log.md` | Monitoreo en memoria de la creación de archivos. |
| **6. Detección (YARA & CAPA)** | Jose Castellanos | `team_rule.yar` / `capa_report.txt` | Regla YARA estructurada y resumen de las capacidades del archivo. |
| **7. Informe Final Integrado** | Jose Castellanos | `team_report.pdf` | Documento unificado con la metodología y conclusiones del equipo. |

---

##  Como ejecutar el análisis

1. **Clonar o descargar:** Descarga este repositorio en formato `.ZIP` dentro de una máquina virtual limpia.
2. **Desactivar protecciones:** Asegúrate de pausar Windows Defender en la VM antes de descomprimir para evitar que bloquee el análisis de la firma YARA.
3. **Analizar:** Utiliza herramientas como `rabin2`, `Ghidra` o `x64dbg` directamente sobre el archivo `team02_sample.exe`.

---
*Desarrollado para la Facultad de Ciencias Físico Matemáticas (FCFM) - Universidad Autónoma de Nuevo León (UANL).*
