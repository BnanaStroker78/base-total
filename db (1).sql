CREATE DATABASE parc_jeux;
USE parc_jeux;

CREATE TABLE UTILISATEUR (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    telephone VARCHAR(20),
    email VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    actif TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT chk_role CHECK (role IN ('admin', 'responsable', 'agent', 'client'))
);

CREATE TABLE JEU (
    id_jeu INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    categorie VARCHAR(50),
    age_min INT DEFAULT 0,
    capacite INT NOT NULL,
    duree_session INT,
    tarif DECIMAL(10,2) NOT NULL,
    etat VARCHAR(30) NOT NULL DEFAULT 'disponible',
    date_mise_en_service DATE,
    actif TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE TYPE_BILLET (
    id_type_billet INT AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL,
    prix DECIMAL(10,2) NOT NULL,
    duree_validite_heures INT,
    description TEXT
);


CREATE TABLE RESPONSABLE (
    id_responsable INT PRIMARY KEY,
    fonction VARCHAR(50),
    date_embauche DATE,
    statut VARCHAR(20),
    FOREIGN KEY (id_responsable) REFERENCES UTILISATEUR(id_utilisateur)
);

CREATE TABLE CLIENT (
    id_client INT PRIMARY KEY,
    FOREIGN KEY (id_client) REFERENCES UTILISATEUR(id_utilisateur)
);

CREATE TABLE AGENT (
    id_agent INT PRIMARY KEY,
    FOREIGN KEY (id_agent) REFERENCES UTILISATEUR(id_utilisateur)
);


CREATE TABLE MAINTENANCE (
    id_maintenance INT AUTO_INCREMENT PRIMARY KEY,
    type_intervention VARCHAR(50),
    description TEXT,
    date_intervention DATE,
    cout DECIMAL(10,2),
    etat VARCHAR(30),
    date_prochaine DATE,
    date_signalement DATE,
    id_jeu INT NOT NULL,
    id_responsable INT NOT NULL,
    FOREIGN KEY (id_jeu) REFERENCES JEU(id_jeu),
    FOREIGN KEY (id_responsable) REFERENCES RESPONSABLE(id_responsable)
);

CREATE TABLE DEPENSE (
    id_depense INT AUTO_INCREMENT PRIMARY KEY,
    categorie VARCHAR(50),
    description TEXT,
    montant DECIMAL(10,2) NOT NULL,
    date_depense DATE NOT NULL,
    type VARCHAR(30),
    justificatif VARCHAR(255),
    id_utilisateur INT NOT NULL,
    id_jeu INT NULL,
    FOREIGN KEY (id_utilisateur) REFERENCES UTILISATEUR(id_utilisateur),
    FOREIGN KEY (id_jeu) REFERENCES JEU(id_jeu)
);

CREATE TABLE ABONNEMENT (
    id_abonnement INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(30) NOT NULL UNIQUE,
    montant DECIMAL(10,2),
    date_debut DATE,
    date_fin DATE,
    id_agent INT NOT NULL,
    id_client INT NOT NULL,
    FOREIGN KEY (id_agent) REFERENCES AGENT(id_agent),
    FOREIGN KEY (id_client) REFERENCES CLIENT(id_client)
);

CREATE TABLE RESERVATION (
    id_reservation INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(30) NOT NULL UNIQUE,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_visite DATE NOT NULL,
    nb_personnes INT NOT NULL,
    montant DECIMAL(10,2),
    date_limite_paiement DATETIME,
    statut VARCHAR(20) NOT NULL DEFAULT 'en attente',
    pdf VARCHAR(255),
    id_client INT NOT NULL,
    id_agent INT NULL,
    FOREIGN KEY (id_client) REFERENCES CLIENT(id_client),
    FOREIGN KEY (id_agent) REFERENCES AGENT(id_agent)
);

CREATE TABLE COMMANDE (
    id_commande INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(30) NOT NULL UNIQUE,
    date_commande DATETIME DEFAULT CURRENT_TIMESTAMP,
    montant_total DECIMAL(10,2),
    mode_paiement VARCHAR(20),
    statut_paiement VARCHAR(20) DEFAULT 'en attente',
    id_client INT NOT NULL,
    id_agent INT NULL,
    FOREIGN KEY (id_client) REFERENCES CLIENT(id_client),
    FOREIGN KEY (id_agent) REFERENCES AGENT(id_agent)
);

CREATE TABLE BILLET (
    id_billet INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    utilise TINYINT(1) NOT NULL DEFAULT 0,
    date_utilisation DATETIME NULL,
    date_expiration DATETIME,
    pdf VARCHAR(255),
    id_type_billet INT NOT NULL,
    id_reservation INT NULL,
    id_commande INT NULL,
    id_agent INT NULL,
    FOREIGN KEY (id_type_billet) REFERENCES TYPE_BILLET(id_type_billet),
    FOREIGN KEY (id_reservation) REFERENCES RESERVATION(id_reservation),
    FOREIGN KEY (id_commande) REFERENCES COMMANDE(id_commande),
    FOREIGN KEY (id_agent) REFERENCES AGENT(id_agent),

    CONSTRAINT chk_billet_source CHECK (
        (id_reservation IS NOT NULL AND id_commande IS NULL)
        OR (id_reservation IS NULL AND id_commande IS NOT NULL)
    )
);

CREATE TABLE AFFECTER (
    id_jeu INT NOT NULL,
    id_responsable INT NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NULL,
    PRIMARY KEY (id_jeu, id_responsable, date_debut),
    FOREIGN KEY (id_jeu) REFERENCES JEU(id_jeu),
    FOREIGN KEY (id_responsable) REFERENCES RESPONSABLE(id_responsable)
);

CREATE TABLE CHOISIR (
    id_reservation INT NOT NULL,
    id_jeu INT NOT NULL,
    PRIMARY KEY (id_reservation, id_jeu),
    FOREIGN KEY (id_reservation) REFERENCES RESERVATION(id_reservation),
    FOREIGN KEY (id_jeu) REFERENCES JEU(id_jeu)
);

CREATE TABLE CONTENIR (
    id_commande INT NOT NULL,
    id_type_billet INT NOT NULL,
    quantite INT NOT NULL,
    prix_unitaire DECIMAL(10,2) NOT NULL,
    sous_total DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_commande, id_type_billet),
    FOREIGN KEY (id_commande) REFERENCES COMMANDE(id_commande),
    FOREIGN KEY (id_type_billet) REFERENCES TYPE_BILLET(id_type_billet)
);