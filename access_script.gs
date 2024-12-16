function main() {
  var files = get_files();
  var editors = ["jwambugu@watuafrica.co.ke"];


  for (var i = 0; i < files.length; i++) {

    var protections = get_protection(files[i]);


    for (var j = 0; j < protections.length; j++) {

      Logger.log(protections[j].getRangeName());
      for (var k = 0; k < editors.length; k++) {

        protections[j].addEditor(editors[k]) ? Logger.log(editors[k] + " added") : Logger.log("operation failed");
      }
    }

  }


};

function get_protection(url) {
  var spr = SpreadsheetApp.openByUrl(url);
  var protections = spr.getProtections(SpreadsheetApp.ProtectionType.SHEET);
  return protections;
}


function get_files() {
  var files = [
  "https://docs.google.com/spreadsheets/d/1HR8MgDDd9ZSBMcaybzKbT-Ab3NfzqV3QwFZwJ8_n3Z4/edit#gid=428503915", 
"https://docs.google.com/spreadsheets/d/1HR8MgDDd9ZSBMcaybzKbT-Ab3NfzqV3QwFZwJ8_n3Z4/edit#gid=428503915", 


  ];

  return files;
}