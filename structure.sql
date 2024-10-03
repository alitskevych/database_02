CREATE TABLE clients (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    birthday date not null,
    status ENUM('active', 'inactive') NOT NULL
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price int not null,
    stock int not null,
    product_category ENUM('Category1', 'Category2', 'Category3', 'Category4', 'Category5') NOT NULL,
    description TEXT
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    client_id CHAR(36),
    product_id INT,
    amount int not null,
    point_id int,
    status varchar(50),
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    foreign key (point_id) references delivery_points(point_id)
);

create table delivery_points (
point_id int auto_increment primary key,
location text not null
);