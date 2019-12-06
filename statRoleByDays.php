
<form  method="post">
  <p>Get result from this date:</p>
  <p>Year:&nbsp&nbsp&nbsp&nbspMonth:&nbsp&nbsp&nbsp&nbspDay:</p>
  <select name="y">
  <option value="2011" >2011</option>
  <option value="2012" >2012</option>
  <option value="2013" >2013</option>
  <option value="2014" >2014</option>
  <option value="2015" >2015</option>
  <option value="2016" >2016</option>
  <option value="2017" >2017</option>
  <option value="2018" >2018</option>
  <option value="2019" >2019</option>
  <option value="2020" >2020</option>
</select>
  <select name="m">
    <option value="01" >01</option>
    <option value="02" >02</option>
    <option value="03" >03</option>
    <option value="04" >04</option>
    <option value="05" >05</option>
    <option value="06" >06</option>
    <option value="07" >07</option>
    <option value="08" >08</option>
    <option value="09" >09</option>
    <option value="10" >10</option>
    <option value="11" >11</option>
    <option value="12" >12</option>
  </select>
  <select name="d">
    <option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option>
    <option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option>
    <option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option>
    <option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option>
    <option value="21">21</option><option value="22">22</option><option value="23">23</option><option value="24">24</option><option value="25">25</option>
    <option value="26">26</option><option value="27">27</option><option value="28">28</option><option value="29">29</option><option value="30">30</option>
    <option value="31">31</option>
  </select>
  <input type="submit" name="submit" value="Get Selected Values" />
</form>

<?php

mysql_connect('localhost', 'myName', 'myPassword');
mysql_select_db('myDB');

if(isset($_POST['submit'])){
$year = $_POST['y'];
$month = $_POST['m'];
$day = $_POST['d'];
$form = $year . "-" . $month . "-" . $day;
echo ("<h1>Your date started from: " . $form . "<h1>");
}

//$form = '2011-02-08';
for($i=0;$i<3500;$i++)
{
    $query = "SELECT id_role,COUNT(*) AS cnt FROM `tb_users_roles_history` WHERE `from`<'$form' AND `to`>='$form' AND id_role!=3 AND id_role!=1 GROUP BY id_role";
    $res = mysql_query($query);
    $count_array[$i]['Date']= $form;
    while($item = mysql_fetch_assoc($res))
      $count_array[$i][$item['id_role']]=$item['cnt'];
    $form = date('Y-m-d', strtotime($form. ' + 1 days'));  
}
header('Content-type: text/html; charset=cp1251');
echo '<table border="1">';
echo("<tr><th>Date</th><th>Business</th><th>Business+</th><th>Ultra</th><th>Ultra+</th></tr>");
foreach($count_array as $item)
{
    echo("<tr><td>$item[Date]</td>");
    echo("<td>$item[4]</td>");
    echo("<td>$item[8]</td>");
    echo("<td>$item[7]</td>");
    echo("<td>$item[11]</td>");
    echo('</tr>');    
}
echo('</table>');
// отрабатывает по адресу https://exkavator.ru/trade/adminz_scripts/statRoleByDays.php

?>


