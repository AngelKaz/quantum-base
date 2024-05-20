$(function(){

    window.addEventListener('message', function(event){
        let item = event.data

        if(item.type == "open"){
            $("#container").fadeIn(150)
        }

        if(item.type == "setChars"){
            let length = item.chars.length
            let charCount = item.charCount
            let chars = 0
            let neededchars = 0

            for (const [key, value] of Object.entries(item.chars)) {
                chars++
            }

            for(let i = 0; i < length; i++){
                InsertChar(item.chars[i])
            } 

            neededchars = charCount-chars
            for(let i = 0; i < neededchars; i++){
                InsertDefaultChar()
            }
        }
    })

    $("body").on('click', '#createchar', function(){
        $(".register").fadeIn(350);
        $(".chars").css('opacity', '0.0')
    })

    $("body").on('click', '#createcharacter', function(){
        let firstname = $("#firstname").val();
        let lastname = $("#lastname").val();
        let age = getAge($("#age").val());
        let height = $("#height").val();
        let sex = $("#sex").val();

        $("#firstnamehelp").html("")
        $("#lastnamehelp").html("")
        $("#agehelp").html("")
        $("#agehelp").html("")
        $("#heighthelp").html("")
        $("#heighthelp").html("")
        
        if(firstname.length < 2){
            $("#firstnamehelp").html("Dit fornavn skal være over 2 bogstaver.")
        } else if(lastname.length < 3){
            $("#lastnamehelp").html("Dit efternavn skal være over 3 bogstaver.")
        } else if(age < 18){
            $("#agehelp").html("Du skal være over 18 år.")
        } else if(age > 99){
            $("#agehelp").html("Du skal være under 99 år.")
        } else if(height > 200){
            $("#heighthelp").html("Din højde skal være under 200 cm")
        } else if(height < 120){
            $("#heighthelp").html("Din højde skal være over 120 cm")
        } else if(sex == "Choose Sex"){
            return
            //$("#sexhelp").html("You need to select a sex")
        } else {
            $.post('https://quantum-multikarakter/CreateChar', JSON.stringify({
                firstname: firstname,
                name: lastname,
                sex: sex,
                age: age,
                height: height
            }))
    
            $("#container").fadeOut(150)
            setTimeout(() => {
                ResetUI()
                $(".chars").empty();
            }, 250);
        }
    })

    $("body").on('click', '#closecreation', function(){
        ResetUI()
    })

    $("body").on('click', '.select', function(){
        let user_id = $(this).attr('userid');
        $.post('https://quantum-multikarakter/SelectChar', JSON.stringify({user_id: user_id}))

        $("#container").fadeOut(150)
        setTimeout(() => {
            ResetUI()
            $(".chars").empty();
        }, 250);
    })


    $('body').on('click', '.delete', function(){
        let id = $(this).attr('userid');

        $(this).closest("div .char").remove();
        InsertDefaultChar()

        $.post('https://quantum-multikarakter/DeleteChar', JSON.stringify({user_id: id}))
    })


    function InsertDefaultChar(){
        $(".chars").append(`
        <div class="char">
            <div class="header">
                <h3>Ingen Karakter</h3>
            </div>
    
            <div class="char-info">
                <i class="fa-solid fa-plus"></i>
            </div>
    
            <button id="createchar" class="create">Opret Karakter</button>
        </div>
        `)
    }
    
    function InsertChar(data){
        $(".chars").append(`
        <div class="char">
            <div class="header">
                <h3>${data.firstname} | ${data.user_id}</h3>
            </div>
    
            <div class="char-info">
                <p>Fulde Navn: <span>${data.firstname} ${data.lastname}</span></p>
                <p>Alder: <span>${data.age}</span></p>
                <p>Køn: <span>${data.gender}</span></p>
                <p>Højde: <span>${data.height} cm</span></p>
                <p>Job: <span>${data.job}</span></p>
                <p>Telefon: <span>${data.phonenumber}</span></p>
                <p>Bank: <span>${data.bank} DKK</span></p>
                <p>Pung: <span>${data.cash} DKK</span></p>
            </div>
            <div class="buttons">
                <button class="select" userid="${data.user_id}">Vælg Karakter</button>
                <button class="delete" userid="${data.user_id}">Slet Karakter</button>
            </div>
        </div>
        `)
    }

    function getAge(dateString) {
        var today = new Date();
        var birthDate = new Date(dateString);
        var age = today.getFullYear() - birthDate.getFullYear();
        var m = today.getMonth() - birthDate.getMonth();

        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }

        return age;
    }

    function ResetUI(){
        $(".register").fadeOut(250);
        $(".chars").css('opacity', '1.0')
        $("#firstname").val('');
        $("#lastname").val('');
        $("#age").val('');
        $("#height").val('');
        $("#sex").val('');
    }
});