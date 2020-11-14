using System;

using Npgsql;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;

namespace Auction
{
    public partial class SignIn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void sign_in_Click(object sender, EventArgs e)
        {
            MD5 md5 = MD5.Create();
            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["postgresUsersConnection"].ToString()))
            {
                
                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("authentication", connection);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("p_number", this.login.Text);
                command.Parameters.AddWithValue("p_password", this.passwordBox.Text);//GetMD5HashData(this.passwordBox.Text));

                string res = command.ExecuteScalar().ToString();

                this.login.Text = res;
            }
        }

        private string GetMD5HashData(string data)
        {
            //create new instance of md5
            MD5 md5 = MD5.Create();

            //convert the input text to array of bytes
            byte[] hashData = md5.ComputeHash(Encoding.Default.GetBytes(data));

            //create new instance of StringBuilder to save hashed data
            StringBuilder returnValue = new StringBuilder();

            //loop for each byte and add it to StringBuilder
            for (int i = 0; i < hashData.Length; i++)
            {
                returnValue.Append(hashData[i].ToString());
            }

            // return hexadecimal string
            return returnValue.ToString();

        }
    }


}