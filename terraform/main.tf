resource "google_compute_network" "efk-cluster-vpc" {
  name                    = "cluster-efk-vpc"
  auto_create_subnetworks = false
  project                 = var.PROJECT_ID
}


resource "google_compute_subnetwork" "efk-cluster-subnet" {

  name          = "efk-cluster-subnet"
  project       = var.PROJECT_ID
  ip_cidr_range = var.IP_CIDR_RANGE
  region        = var.REGION
  network       = google_compute_network.efk-cluster-vpc.self_link
  depends_on    = [google_compute_network.efk-cluster-vpc, ]
}

resource "google_compute_address" "academy-bastion-pub-ip" {
  name     = var.BASTION_PUBLIC_IP_NAME
  region   = var.REGION
  project  = var.PROJECT_ID

}
//                  FRW 
//*************************************************************************************//

resource "google_compute_firewall" "efk-cluster-allow-internal-fw" {
  name        = "allow-kubespray-internal"
  network     = google_compute_network.efk-cluster-vpc.self_link
  project     = var.PROJECT_ID

  # Allows internal communication across all protocols
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
  }
  allow {
    protocol = "tcp"
  }

  source_tags   = [var.CLUSTER_FW_ALLOW_INTERNAL_TAG]
  source_ranges = [var.IP_CIDR_RANGE]
  depends_on = [google_compute_network.efk-cluster-vpc, google_compute_subnetwork.efk-cluster-subnet,]
}

resource "google_compute_firewall" "academy-cluster-allow-bastion-fw" {
  name        = format("%s-allow-bastion-fw", var.CLUSTER_NAME)
  network     = google_compute_network.efk-cluster-vpc.self_link
  project     = var.PROJECT_ID

  # Allows internal communication across ssh protocol
  allow {
    protocol = "tcp"
       ports    = ["22"]
  }

  source_tags   = [var.CLUSTER_FW_ALLOW_BASTION_TAG]
  source_ranges = ["0.0.0.0/0"]
  depends_on = [google_compute_network.efk-cluster-vpc, google_compute_subnetwork.efk-cluster-subnet,]

}
  //         COMPUTE INSTANCES
 //*************************************************************//
resource "google_compute_instance" "bastion" {
  name = "kubespray-bastion-machine"
  machine_type = var.MACHINE_TYPE
  zone         = var.ZONE
  project      = var.PROJECT_ID
 
  tags = [var.CLUSTER_FW_ALLOW_INTERNAL_TAG, var.CLUSTER_FW_ALLOW_BASTION_TAG]
   
  boot_disk {
    initialize_params {
      image = var.OS_IMAGE
    }
  }
  
  // Networking
  network_interface {
    network     = google_compute_network.efk-cluster-vpc.self_link
    subnetwork  = google_compute_subnetwork.efk-cluster-subnet.self_link

    // For external networking
    access_config {
      nat_ip = google_compute_address.academy-bastion-pub-ip.address
    }
  }
  // Only cluster admin has the private key to access bastion machine via ssh
  metadata = {
    sshKeys = "root:${var.BASTION_PUB_KEY}"
  }
  
  depends_on= [google_compute_address.academy-bastion-pub-ip,google_compute_network.efk-cluster-vpc, google_compute_subnetwork.efk-cluster-subnet,]
}
//**************************masters**************************
resource "google_compute_instance" "master"  {

  count        =  var.MASTER_COUNT
  name         = format("%s%s", "kubespray-master", count.index + 1)
  machine_type = var.MACHINE_TYPE
  zone         = var.ZONE
  project      = var.PROJECT_ID

  tags = [var.CLUSTER_FW_ALLOW_INTERNAL_TAG]

  boot_disk {
    initialize_params {
      image = var.OS_IMAGE
    }
  }

  // Networking
  network_interface {
    network     = google_compute_network.efk-cluster-vpc.self_link
    subnetwork  = google_compute_subnetwork.efk-cluster-subnet.self_link

    // For external networking
    access_config {
    
        }
  }

  metadata = {
    sshKeys = "root:${var.BASTION_PUB_KEY}"
  }

  depends_on = [google_compute_network.efk-cluster-vpc, google_compute_subnetwork.efk-cluster-subnet,]
}

// ************** workers***********************************************
resource "google_compute_instance" "worker" {

  count        =    var.WORKER_COUNT
  name         = format("%s%s", "kubespray-worker", count.index + 1)
  machine_type = var.MACHINE_TYPE
  zone         = var.ZONE
  project      = var.PROJECT_ID

  tags = ["allow-kubespray-internal"]

  boot_disk {
    initialize_params {
      image = var.OS_IMAGE
    }
  }

  // Networking
  network_interface {
    network     = google_compute_network.efk-cluster-vpc.self_link
    subnetwork  = google_compute_subnetwork.efk-cluster-subnet.self_link

    // For external networking
    access_config {
      // 
    }
  }

  metadata = {
    sshKeys = "root:${var.BASTION_PUB_KEY}"
  }

  depends_on = [google_compute_network.efk-cluster-vpc, google_compute_subnetwork.efk-cluster-subnet,]
}