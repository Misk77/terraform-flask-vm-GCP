// Configure for the GCP
provider "google"{
 credentials = "${file("michelskoglund-CodeLabs-087b72ea410a.json")}"
 project = "michelskoglund-codelabs"
 region = "us-west1"
}

// terraform plugin for creating rand ids
resource "random_id" "instance_id" {
 byte_length = 8

}

// A single GCE instances
resource "google_compute_instance" "default"{
 name = "flask-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone = "us-west1-a"

 boot_disk  {
   initialize_params {
	image = "debian-cloud/debian-9"

  }
}



// Make sure flask is installed on all the new instances for later steps
metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"
network_interface {
 network = "default"

 access_config {
  // This for giving the vm an external ip address
  }
 }
metadata = {
   ssh-keys = "michelskoglund:${file("~/.ssh/id_rsa.pub")}"
 }
}

// A variable for extracting the external ip of the instance
output "ip" {
 value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}

resource "google_compute_firewall" "default" {
 name    = "flask-app-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["5000"]
 }
}
