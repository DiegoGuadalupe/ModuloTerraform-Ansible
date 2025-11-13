# ModuloTerraform-Ansible
En este repositorio se guardan los archivos de la práctica final de Terrafrom. <br>
Prerrequisitos:
- Instalar pip en la máquina dónde se va a ejecutar el código.
- Instalar boto3 por medio de pip en la misma máquina.
- Instalar Ansible en la misma máquina.
- Instalar Terraform en la misma máquina.

## 📁 Directorio principal (`ModuloTerraform-Ansible`)
- Parte 1 Bucket S3: En este directorio se encuentran los archivos de terraform relacionados con la parte de la static web en un bucket de S3.
- Parte 2 Integracion: En este directorio se encuentran las carpetas de Ansible, de Terraform y el archivo que ejecuta todo.

### 📂 Ansible/
- site.yml: Archivo principal que ejecuta los dos roles, correspondientes a la configuración de la base de datos y del webserver.
- inventory_aws_ec2.yml: Archivo que contiene las llamadas a la api de aws de Ansible para obtener el inventario dinámico.
- ansible.cfg: Archivo de configuración de Ansible
- roles/: Contiene los dos roles propuestos: El de db y el de web.
- group_vars/: Definición de variables para cada grupo de máquinas en aws.

## Modo de ejecución

Para ejecutar la primera parte del bucket S3, basta con movernos al directorio de **Parte 1 Bucket S3** y ejecutar los comandos:

- Inicializar Terraform: `terraform init`  
- Crear el plan: `terraform plan`  
- Aplicar el plan: `terraform apply`  

Así crearemos el bucket de S3 y, por medio de la consola, veremos el **endpoint** con el que poder ver la static web.

Para ejecutar la segunda parte de integración, debemos movernos al directorio **Parte 2 Integracion** y ejecutar el archivo `deploy.sh` de la siguiente manera:

- Ejecución del shell script master: `./deploy.sh`  

Si nos falla la ejecución por falta de permisos, debemos aplicar el siguiente comando `chmod 777 deploy.sh`.
Asimismo, si al crear la estructura de AWS por medio de Terraform, vemos que no avanza, presionaremos Crtl + C, esperaremos a que acabe y lo volveremos a ejecutar. <br>
Así crearemos toda la estructura de AWS y los configuraremos por medio de Ansible.


