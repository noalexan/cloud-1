# cloud-1

## This project consists of automating application deployment on a cloud server. It uses [Ansible](https://docs.ansible.com/ansible/latest/index.html) to manage provisioning and configuration. It involves writing `playbook` to orchestrate container deployment, as well as managing and optimizing deployment environments.

The goal of this project is to learn to use [Ansible](https://docs.ansible.com/ansible/latest/index.html) and a cloud service provider, and to understand what a 'cloud' is.

The first thing we did with [Noah](https://github.com/noalexan) was to choose a cloud provider, and we chose [Digital Ocean](https://www.digitalocean.com/). **Why?** Because we have $200 in free credits to complete this project.

# 1. Creation of our Digital Ocean account, team and droplet

We activate our Github student plan, and it contain *200 $* free credits for Digital Ocean
After that, we enjoying with our droplet, discover the world of the **cloud**, check all prameter we can modify, etc...

# 2. Refocusing on the subject of the project

The project said :
```txt
It is imperative to provide a functional site equivalent to the one obtained with Inception just using your script.
```

It means the automation software (here : Ansible) must launch a **full Wordpress application (like [Incpetion](https://github.com/Nimpoo/Inception)) in any remote workstation/server**. Adding to this we must respect the term of <u>**idempotent**</u>.

- <u>**Idempotency**</u> : Idempotence means that an operation has the same effect whether it is applied once or several times. For example, the absolute value is idempotent: | | − 5 | | = | − 5 |, both sides being equal to 5.

In our context here, it means we must always has th **SAME RESULT** in any remote workstation/server we launch our Ansible script. I should have the **EXACT SAME WORDPRESS** if I save the datas of the containers.

## _Let's start with how Ansible works !_

# 3. <u>Ansible</u> : `playbook`, `task`, `managed nodes`, etc...

I suggest you to do the [Getting started](https://docs.ansible.com/ansible/latest/getting_started/get_started_ansible.html) to familiarise with Ansible.

- **Control node** : Machine where Ansible is installed. It's from this machine we run Ansible's commands for launch our scripts (`ansible-playbook` for the most common)

- **Managed node** : A distant system, a host that Ansible can control from the **control node** (here, it's our droplet from Digital Ocean).

- **`inventory`** : List of **managed node** whis are logically organised. We create an `inventory` in the **control node** for describe our target host/distant machine, there becomes **managed nodes**.<br />
Exemple of an `inventory.yml` :
```yml
Hosts_for_my_WordPress_App:

  hosts:
    Wordpress:
      ansible_host: 192.0.2.50

    MariaDB:
      ansible_host: 192.0.2.51

    PHPMyadmin:
      ansible_host: 192.0.2.52
```

`Hosts_for_my_WordPress_App` : Name of my the **group**.
<br />
`hosts` : List of all the host in the group.
<br />
`Wordpress` : Name of my **managed node**.
<br />
`ansible_host` : Keyword for assign an IP adress to my **managed node**

- **playbook** : It's a blueprint Ansible uses to deploy and configure the **managed nodes**. It's a list of **`plays`** that defines the order in which Ansible should perform the operations.

- **`play`** : Ordered list of tasks mapped to managed nodes in an inventory

- **module** : A binary Ansible run on **managed nodes**. The Ansible's **modules** are groupeed in collection with one *EQCN* (Fully Qualified Collection Name) for each **module**.

And now, an exemple of a `playbook.yml`

```yml
---
- name: Ansible Training
  hosts: Digital_Ocean
  tasks:
    - name: Ping test
      ansible.builtin.ping:

    - name: Print message
      ansible.builtin.debug:
        msg: Hello World
```

`name` : Name of the **`playbook`**.
<br />
`hosts` : The group of hosts we want to target (that we have define previously in the file `inventory.yml`)
<br />
`tasks` : Assign a list of tasks Ansible will do
<br />
`name` : Name of the task (arbitrary)
<br />
`ansible.builtin.ping` : A **module**. This module ping the host for exemple

## REFOCUSING ON THE PROJECT

<u>Now we know all that, what does this look like from the perspective of the project guidelines ?</u>

# 4. The `inventory` and a `playbook` for a WordPress App

## 4.1 The `inventory`

The subject says :
```txt
The script must be able to function in an automated way with for only assumption
an ubuntu 20.04 LTS like OS of the target instance running an SSH daemon and
with Python installed.
```

We need only one distant machine. So let's do the `inventory.yml` :
```yml
Digital_Ocean:
  hosts:
    DO-host:
      ansible_host: [IP ADDRESS]
```

### `inventory` finished !

## 4.2 The `playbook`

The subject says :
```txt
- Your applications will run in separate containers that can communicate with each other (1 process = 1 container)
- The services will be the different components of a WordPress to install by yourself. For example Phpmyadmin, MySQL, ...
- You must have a docker-compose.yml.
- You will need to ensure that your SQL database works with WordPress and PHP-
MyAdmin.
```

We need the following things :
- Only 1 host.
- 3 container lauch in our host : **WordPress**, **PHPMyAdmin** and **MariaDB**.
- A `docker-compose.yml` that deploy these 3 containers (and a volume).
In case of reboot all the data of the site are persisted (images, user accounts, articles,
...).

And we need to "add" an important thing : the <u>**IDEMPOTENCY**</u>. We need to create a functionnal `playbook` for any differents machine, and the datas still persists.

Here's what we need to do with this `playbook` :

1. Update and upgrade the packages of the target host.
2. Install `docker` and `docker-compose`.
3. Setup our containers.
4. Launch our containers.

We need to introduce : the `roles`

## 4.3 The `roles`

We can create and generate a `role` with the following command :
```sh
ansible-galaxy init [ROLE_NAME]
```

`roles` are used for organised the tasks of a playbook do. In a `role`, we only need th folder `task` for doing what we want to do.
