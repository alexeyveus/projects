variable "region_numbers" {
  type = "map"
  default = {
    eu-west-1 = 1
    eu-west-2 = 2
  }
}

variable "az_numbers" {
  type = "map"
  default = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
    g = 7
    h = 8
    i = 9
    j = 10
    k = 11
    l = 12
    m = 13
    n = 14
  }
}

variable "project_cidrs" {
  type = "map"
  default = {
    wiki-prod      = "10.0.0.0/12"
  }
}
