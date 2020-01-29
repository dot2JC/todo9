#!/bin/bash

# Set IFS Value
   IFS_Save=${IFS}
   IFS=,

# Variable Declaration
   totalcount=0 
   spacecount=0 
   comcount=0 
   useradded=0
   groupadded=0
   usersdel=0
   groupsdel=0

   declare -a user_group
   declare -a group_group

#################### Add Users + Group ####################
if [ ${1} = '-a' ]
then
	while read fname mname lname gname
	do
		let ++totalcount
      	if [ -z ${fname} ]
      	then
         	let ++spacecount
       	elif [ ${fname:0:1} = '#' ]
      	then
         	let ++comcount
       	else
#################### BEGIN Add Users ####################
         	username=${fname:0:1}${mname:0:1}${lname}
         	useradd ${username} 2> >( while read line; do echo "$(date): ${line}"; done >> error.txt )
         	if [ ${?} = 9 ]
         	then
            		logger -p local3.error "User ${username} already exists"
            		exit 30
         	else
            		logger -p local3.error "User ${username} added"
            		let ++useradded
            		logger -p local3.error "${username}:password" | chpasswd
            		chage --lastday 0 ${username}
         	fi
#################### BEGIN Add Group ####################
         	groupadd ${gname} 2> >( while read line; do echo "$(date): ${line}"; done >> error.txt )
         	if [ ${?} = 9 ]
         	then
            		logger -p local3.error "Group ${gname} already exists"
         	else
            		logger -p local3.error "Group ${gname} added"
            		let ++groupadded
         	fi
#################### BEGIN Add User to Group ####################
         	usermod -aG ${gname} ${username} 2> >( while read line; do echo "$(date): ${line}"; done >> error.txt )
         	echo "User ${username} has been added to the group ${gname}"
      	fi
	done < ${2}
   echo "The number of users added is ${useradded} and the number of groups added is ${groupadded}"
fi
#################### Delete users and groups with confirmation ####################
if [ ${1} = '-d' ]
then
	while read fname mname lname gname
   	do
      		let ++totalcount
      		if [ -z ${fname} ]
      		then
         		let ++spacecount
      		elif [ ${fname:0:1} = '#' ]
      		then
         		let ++comcount
      		else
         		username=${fname:0:1}${mname:0:1}${lname}
         		user_group+="${username}," 
         		group_group+="${gname},"
			#echo "${group_group}"
      		fi
   	done <${2}
	#echo "${group_group}"
   	echo "Do you want to delete the following users:"
   	for i in ${user_group[@]}
   	do
      		echo "${i}"
   	done
   	read -p "Yes (Y) or No (N): " delgroup </dev/tty
   	if [ ${delgroup} = 'Y' ] || [ ${delgroup} = 'y' ]
   	then
      		echo "Are you sure you want to delete the following users:"
      		for i in ${user_group[@]}
      		do
         		echo "${i}"
      		done
      		read -p "Yes (Y) or No (N): " delgroup </dev/tty
      		for i in ${user_group[@]}
      		do
         		userdel -r ${i} 2> >( while read line; do echo "$(date): ${line}"; done >> error.txt )
         		if [ ${?} = 6 ]
         		then
            			echo "User previously deleted"
         		else
            			echo "User ${i} has been deleted"
            			let ++usersdel
         		fi  
      		done
#something about how the remove groups shit aint working >:(

      		for i in ${group_group[@]}
      		do
			#echo "${i}"
         		getent group ${i} >> test.txt
         		val1=$(cut -d ':' -f 4  test.txt)
			#echo "${val1}"
         		if [ -z ${val1} ]
         		then
            			groupdel ${i} 2> >( while read line; do echo "$(date): ${line}"; done >> error.txt )
            			if [ ${?} = 6 ]
            			then
               				echo "Group previously deleted"
            			else
               				echo "Group ${i} has been deleted"
               				let ++groupsdel
            			fi
         		fi
         	rm test.txt
      		done
   	fi
   	echo "The number of users deleted is ${usersdel} and the number of groups deleted is ${groupsdel}"
fi
####################  Force Delete Users and Group (w/o confirm) #################### 
if [ ${1} = '-df' ]
then
   	while read fname mname lname gname
   	do
      		let ++totalcount
      		if [ -z ${fname} ]
      		then
         		let ++spacecount
      		elif [ ${fname:0:1} = '#' ]
      		then
         		let ++comcount
      		else
         		username=${fname:0:1}${mname:0:1}${lname}
         		userdel -rf ${username} 2> >( while read line; do echo "$(date): ${line}"; done >> error.txt ) 
         		if [ ${?} = 6 ]
         		then
            			echo "User ${username} previously deleted"
         		else
            			echo "User ${username} has been deleted"
            			let ++usersdel
         		fi
         		getent group ${gname} >> test.txt
         		val1=$(cut -d ':' -f 4  test.txt)
         		if [ -z ${val1} ]
         		then
            			groupdel ${gname} 2> >( while read line; do echo "$(date): ${line}"; done >> error.txt )
            			if [ ${?} = 6 ]
               			then
               				echo "Group previously deleted"
            			else
               				echo "Group ${gname} has been deleted"
               				let ++groupsdel
            			fi
         		fi
         		rm test.txt
      		fi
   		done < ${2}
   	echo "The number of users deleted is ${usersdel} and the number of groups deleted is ${groupsdel}"
fi
#################### Catch Error in First Argument ####################
if [ ${1} != '-a' ] && [ ${1} != '-d' ] && [ ${1} != '-df' ]
then
   echo "Please enter a valid argument."
fi
#################### Echo Values ####################
echo "----------------------------------------------------"
echo "The total number of lines read are: ${totalcount}"
echo "The number of lines with spaces are: ${spacecount}"
echo "The number of lines with comments are: ${comcount}"
echo "----------------------------------------------------"

IFS=${IFS_Save}

exit 0
