<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registration</title>
    <link rel="stylesheet" type="text/css" href="../CSS/REGISTRATION.css">
</head>
<body>

<%
    // Initialize variables for error/success messages
    String errorMessage = null;
    String successMessage = null;

    // Check if the form has been submitted
    if ("POST".equalsIgnoreCase(request.getMethod())) {

        // PostgreSQL connection details from environment variables
        final String DB_URL = "jdbc:postgresql://" + System.getenv("DB_HOST") + ":" + System.getenv("DB_PORT") + "/" + System.getenv("DB_NAME");
        final String DB_USER = System.getenv("DB_USER");
        final String DB_PASSWORD = System.getenv("DB_PASSWORD");

        // Get form parameters
        String name = request.getParameter("name");
        String mobile = request.getParameter("mobile");
        String pincode = request.getParameter("pincode");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String password = request.getParameter("password");
        String altPhone = request.getParameter("alt-phone");
        String addressType = request.getParameter("address-type");

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            // Load PostgreSQL JDBC driver
            Class.forName("org.postgresql.Driver");

            // Connect to the database
            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Check if mobile number already exists in the users table
            String checkSql = "SELECT * FROM users WHERE mobile = ?";
            preparedStatement = connection.prepareStatement(checkSql);
            preparedStatement.setString(1, mobile);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {
                errorMessage = "Already Registered with this number!";
            } else {
                // Convert dob string (yyyy-MM-dd) to java.sql.Date
                java.sql.Date sqlDob = null;
                if (dob != null && !dob.isEmpty()) {
                    sqlDob = java.sql.Date.valueOf(dob); // Converts "YYYY-MM-DD" to java.sql.Date
                }

                // Insert data into the users table
                String sqlUser = "INSERT INTO users (name, mobile, pincode, dob, address, city, state, password, alt_phone, address_type) "
                                 + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                preparedStatement = connection.prepareStatement(sqlUser);
                preparedStatement.setString(1, name);
                preparedStatement.setString(2, mobile);
                preparedStatement.setString(3, pincode);
                preparedStatement.setDate(4, sqlDob); // Fixed here
                preparedStatement.setString(5, address);
                preparedStatement.setString(6, city);
                preparedStatement.setString(7, state);
                preparedStatement.setString(8, password);
                preparedStatement.setString(9, (altPhone != null && !altPhone.isEmpty()) ? altPhone : null);
                preparedStatement.setString(10, addressType);

                int rowsAffected = preparedStatement.executeUpdate();

                if (rowsAffected > 0) {
                    // Combine address fields into a single string for addresses table
                    String fullAddress = address + ", " + city + ", " + state + ", " + pincode + " - " + mobile;

                    String sqlAddress = "INSERT INTO addresses (mobile, address) VALUES (?, ?)";
                    preparedStatement = connection.prepareStatement(sqlAddress);
                    preparedStatement.setString(1, mobile);
                    preparedStatement.setString(2, fullAddress);

                    int addressRowsAffected = preparedStatement.executeUpdate();

                    if (addressRowsAffected > 0) {
                        response.sendRedirect("LOGIN-PAGE.jsp");
                    } else {
                        errorMessage = "Failed to insert address details. Please try again.";
                    }
                } else {
                    errorMessage = "Failed to submit the form. Please try again.";
                }
            }

        } catch (ClassNotFoundException e) {
            errorMessage = "Error: Unable to load the PostgreSQL driver.";
            e.printStackTrace();
        } catch (SQLException e) {
            errorMessage = "Error: Unable to connect to the database.";
            e.printStackTrace();
        } finally {
            try {
                if (resultSet != null) resultSet.close();
                if (preparedStatement != null) preparedStatement.close();
                if (connection != null) connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>

<table>
    <tr>
        <td>
            <img src="../IMAGES/registration-photo.png" alt="Registration Image">
        </td>
        <td>
            <form class="form-container" method="post">
                <div class="row">
                    <div class="input-group">
                        <% if (errorMessage != null) { %>
                            <p style="color: red; text-align: center; padding: 10px;"><%= errorMessage %></p>
                        <% } %>
                    </div>
                </div>
                <div class="row">
                    <div class="input-group">
                        <label for="name">Name<span id="Required">*</span></label>
                        <input type="text" id="name" name="name" placeholder="Name" required>
                    </div>
                    <div class="input-group">
                        <label for="mobile">Mobile number<span id="Required">*</span></label>
                        <input type="tel" id="mobile" name="mobile" placeholder="10-digit mobile number" required maxlength="10">
                    </div>
                </div>
                <div class="row">
                    <div class="input-group">
                        <label for="pincode">Pincode<span id="Required">*</span></label>
                        <input type="text" id="pincode" name="pincode" placeholder="Pincode" required>
                    </div>
                    <div class="input-group">
                        <label for="dob">Date of Birth<span id="Required">*</span></label>
                        <input type="date" id="dob" name="dob" required>
                    </div>
                </div>
                <div class="row">
                    <div class="input-group">
                        <label for="address">Address<span id="Required">*</span></label>
                        <textarea id="address" name="address" placeholder="Area/Street" required></textarea>
                    </div>
                </div>
                <div class="row">
                    <div class="input-group">
                        <label for="city">City/District/Town<span id="Required">*</span></label>
                        <input type="text" id="city" name="city" placeholder="City/District" required>
                    </div>
                    <div class="input-group">
                        <label for="state">State<span id="Required">*</span></label>
                        <select id="state" name="state" required>
                            <option value="">Select State</option>
                            <option value="andhra-pradesh">Andhra Pradesh</option>
                            <option value="arunachal-pradesh">Arunachal Pradesh</option>
                            <option value="assam">Assam</option>
                            <option value="bihar">Bihar</option>
                            <option value="chhattisgarh">Chhattisgarh</option>
                            <option value="goa">Goa</option>
                            <option value="gujarat">Gujarat</option>
                            <option value="haryana">Haryana</option>
                            <option value="himachal-pradesh">Himachal Pradesh</option>
                            <option value="jharkhand">Jharkhand</option>
                            <option value="karnataka">Karnataka</option>
                            <option value="kerala">Kerala</option>
                            <option value="madhya-pradesh">Madhya Pradesh</option>
                            <option value="maharashtra">Maharashtra</option>
                            <option value="manipur">Manipur</option>
                            <option value="meghalaya">Meghalaya</option>
                            <option value="mizoram">Mizoram</option>
                            <option value="Nagaland">Nagaland</option>
                            <option value="Odisha">Odisha</option>
                            <option value="Punjab">Punjab</option>
                            <option value="Rajasthan">Rajasthan</option>
                            <option value="Sikkim">Sikkim</option>
                            <option value="Tamil-nadu">Tamil Nadu</option>
                            <option value="Telangana">Telangana</option>
                            <option value="tripura">Tripura</option>
                            <option value="uttar-pradesh">Uttar Pradesh</option>
                            <option value="uttarakhand">Uttarakhand</option>
                            <option value="west-bengal">West Bengal</option>
                            <option value="andaman-nicobar">Andaman and Nicobar Islands</option>
                            <option value="chandigarh">Chandigarh</option>
                            <option value="dadra-nagar-haveli-daman-diu">Dadra and Nagar Haveli and Daman and Diu</option>
                            <option value="delhi">Delhi</option>
                            <option value="jammu-kashmir">Jammu and Kashmir</option>
                            <option value="ladakh">Ladakh</option>
                            <option value="lakshadweep">Lakshadweep</option>
                            <option value="puducherry">Puducherry</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="input-group">
                        <label for="password">Password<span id="Required">*</span></label>
                        <input type="text" id="password" name="password" placeholder="Password" required>
                    </div>
                    <div class="input-group">
                        <label for="alt-phone">Alternate Phone</label>
                        <input type="tel" id="alt-phone" name="alt-phone" placeholder="Alternate Phone">
                    </div>
                </div>
                <div class="row">
                    <div class="input-group">
                        <label>Address Type<span id="Required">*</span></label>
                        <div>
                            <label>
                                <input type="radio" id="home" name="address-type" value="Home" required>
                                Home
                            </label>
                            <label>
                                <input type="radio" id="work" name="address-type" value="Work">
                                Work
                            </label>
                        </div>
                    </div>
                </div>
                <button type="submit" class="btn">Save</button>
                <script>
                    document.addEventListener("DOMContentLoaded", () => {
                        const form = document.querySelector(".form-container");

                        form.addEventListener("input", (event) => {
                            validateField(event.target);
                        });

                        form.addEventListener("submit", (event) => {
                            const fields = form.querySelectorAll("input, textarea, select");
                            let isValid = true;

                            fields.forEach((field) => {
                                if (!validateField(field)) {
                                    isValid = false;
                                }
                            });

                            const addressTypeRadios = document.querySelectorAll('input[name="address-type"]');
                            const isRadioValid = [...addressTypeRadios].some((radio) => radio.checked);
                            const addressGroup = document.querySelector('.input-group input[name="address-type"]').parentElement;

                            if (!isRadioValid) {
                                isValid = false;
                                addressGroup.style.border = "1px solid red";
                            } else {
                                addressGroup.style.border = "";
                            }
                        });

                        function validateField(field) {
                            const value = field.value.trim();
                            let isValid = true;

                            field.style.borderColor = "";

                            switch (field.id) {
                                case "name":
                                case "address":
                                case "city":
                                    isValid = value.length >= 4;
                                    break;
                                case "password":
                                    isValid = /^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{7,}$/.test(value);
                                    break;
                                case "mobile":
                                case "alt-phone": 
                                    isValid = value.length === 0 || /^\d{10}$/.test(value);
                                    break;
                                case "pincode":
                                    isValid = /^\d{6}$/.test(value);
                                    break;
                                case "state":
                                    isValid = value !== "";
                                    break;
                                default:
                                    break;
                            }
                            if (!isValid) {
                                field.style.borderColor = "red";
                            }

                            return isValid;
                        }
                    });
                </script>
            </form>
        </td>
    </tr>
</table>

</body>
</html>
