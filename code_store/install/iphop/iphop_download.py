import sys
import os
import argparse
import hashlib
import logging
## This is to do a download with requests, and a progressbar, but we do not use this in the end
import requests
import click
import subprocess as sp



def fetch_arguments(parser,root_dir,db_path_default):
	parser.set_defaults(func=main)
	parser.set_defaults(program="download")
	parser.add_argument('--db_dir','-d', dest='db_dir', required=True, default='none', help='Output directory where the database files will be downloaded')
	parser.add_argument('--db_version','-dbv', dest='db_version', required=False, default='iPHoP.latest_rw', help='To download a specific version of the database (see README for options)')
	parser.add_argument('--split','-s', dest='split',  action='store_true', required=False, default=False, help='Download the database by chunk of 10Gb. iPHoP will not download a chunk if the file is already present and with the correct md5sum. Can be useful for slower connections and/or to be able to stop and resume a database download')
	parser.add_argument('--no_prompt','-n', dest='no_prompt',  action='store_true', required=False, default=False, help='Skip all the user prompts, which are here to make sure the program does not take too much resource and/or does not erase some previous version of the database. Use it at your own risk')
	parser.add_argument('--full_verify','-f', dest='full_verify', action='store_true', required=False, default=False, help='This is to verify that a database is complete (Note: the database will NOT be downloaded)\n In this mode, the path provided should be the full database path (i.e. the directory where the db/ and db_infos/ folders are located)')

def main(args):
	## Important stable information
	args["base_url"] = "https://portal.nersc.gov/cfs/m342/iphop/db/"
	args["block_size"] = 1024
	logging.basicConfig(level=logging.DEBUG, format="%(message)s")
	# logging.basicConfig(level=logging.INFO, format="%(message)s")
	logger = logging.getLogger(__name__)
	#
	## First verify that the input file and the host database directory are both here
	if not os.path.exists(args["db_dir"]):
		logger.info(f"Pblm, I could not find folder {args['db_dir']}, and I do need a folder to put all these files")
		sys.exit(1)
	if args["full_verify"]:
		full_verify(args["db_dir"],logger)
	else:
		## Warning about spacer requirements
		## Also warning about length of the whole process
		logger.info("### WARNING ###\niPHoP database is pretty big, and will require around ~ 350Gb of disk space and some time to download and set up (except if you are downloading the test database, in which case it's only ~ 5Gb). Are you sure you want to continue ?\n################")
		response = single_yes_or_no_question("Please confirm you are ready to download the iPHoP database now. ",args["no_prompt"])
		if response:
			## Downloading if database directory is empty
			dirlist = os.listdir(args["db_dir"])
			db_filename = args["db_version"]
			# Checking if the list is empty or not
			if len(dirlist) != 0:
				response = single_yes_or_no_question(f"directory {args['db_dir']} is not empty, and I don't want to erase anything by mistake. Are you sure this is the right folder. ",args["no_prompt"])
				if response:
					logger.info("Ok, we trust you")
				else:
					sys.exit("Ok, we stop right here")
			# We first check what files we need to download - if only one md5, it's easy, a simple file. If multiple, then the first line is for the merge, the following lines are for the different parts (20Gb chunks)
			url_md5 = args["base_url"]+db_filename+".tar.gz.md5"
			dwnded_archive_md5sum = os.path.join(args['db_dir'],db_filename+".tar.gz.md5")
			dwnd_cmd = f"wget -O {dwnded_archive_md5sum} {url_md5}"
			p = sp.Popen(dwnd_cmd, shell=True)
			p.wait()
			expected_md5 = []
			split_file_names = []
			db_real_name = ""
			dwnded_archive = ""
			# response = single_yes_or_no_question("Please confirm you are ready to download the iPHoP database now. ")
			with open(dwnded_archive_md5sum, "r", newline='') as f:
				for line in f:
					tab = line.strip().split(" ")
					if len(tab) > 1: ## Regular md5 line -> md5sum / file name (starting with the full db, then going through each split)
						expected_md5.append(line.strip().split(" ")[0])
						split_file_names.append(line.strip().split(" ")[2])
					else: ## Last line should be only the db name, and no second column
						db_real_name = tab[0]
						## Because the last line is only
			if db_real_name == "":
				logger.warning(f"We could not identify the database version you are trying to download, please check the Readme to make sure the name {db_filename} is correct")
				sys.exit(1)
			logger.debug(f"expected md5 {expected_md5}")
			if len(expected_md5)==1 or args["split"] == False:
				logger.info("We download the database as a single file")
				tar_file = download_with_attempts(split_file_names[0],expected_md5[0],args,logger)
				dwnded_archive = tar_file
			elif len(expected_md5)>1:
				tar_files = []
				logger.info(f"We will try to download the database in {(len(expected_md5)-1)} chunks")
				for i in range(1,len(expected_md5)):
					tmp_tar_file = download_with_attempts(split_file_names[i],expected_md5[i],args,logger)
					tar_files.append(tmp_tar_file)
				combined_file = custom_combine(tar_files,db_filename,expected_md5[0],args,logger)
				dwnded_archive = combined_file
			# db_name = get_db_name(dwnded_archive) ## now in the md5 file
			logger.debug(f"All good, now we extract the database {db_real_name}")
			xtract_cmd = f"tar -xf {dwnded_archive} -C {args['db_dir']}"
			logger.debug(f"{xtract_cmd}")
			p = sp.Popen(xtract_cmd, shell=True)
			p.wait()
			db_path = os.path.join(args["db_dir"],db_real_name)
			db_path = os.path.abspath(db_path)
			logger.info(f"All done ! The database has been put in {db_path} === This is the path you need to give to iPHoP (using the -d argument)")
			logger.info(f"If you need to save space, you should be able to delete {dwnded_archive} (although we would recommend doing so only after you checked that the database download indeed worked as expected)")


def custom_combine(tab_tar_files,db_filename,expected_md5,args,logger):
	combined_file = os.path.join(args['db_dir'],db_filename+".tar.gz")
	cmd_line = "cat " + " ".join(tab_tar_files) + " > " + combined_file
	p = sp.Popen(cmd_line, shell=True)
	p.wait()
	logger.debug(f"Checking md5sum of {combined_file}")
	real_md5 = md5(combined_file)
	logger.debug(f"We expected {expected_md5} and got {real_md5}")
	if expected_md5 != real_md5:
		sys.exit("ERROR, the md5 check failed for the combined archive -- we stop here")
	else:
		logger.debug(f"{combined_file} is all good and has the right md5, we are ok")
		return combined_file

def download_with_attempts(db_filename,expected_md5,args,logger):
	# url = args["base_url"] + db_filename + ".tar.gz"
	# dwnded_file = os.path.join(args['db_dir'],db_filename+".tar.gz")
	# if db_chunk!="":
		# url = url + "." + db_chunk
		# dwnded_file = dwnded_file + "." + db_chunk
	url = args["base_url"] + db_filename
	dwnded_file = os.path.join(args['db_dir'],db_filename)
	## Test if file exists - if so we don't need to download
	tag = 0 ## tag to know if everything is ok
	if os.path.exists(dwnded_file):
		logger.debug(f"Checking md5sum of {dwnded_file} because we already have a local version")
		real_md5 = md5(dwnded_file)
		if expected_md5 == real_md5:
			logger.debug(f"{dwnded_file} is already here, and has the right md5, so we are ok we do not need to download again")
			tag = 1
		else:
			logger.debug(f"{dwnded_file} has the wrong md5, so we re-attempt to download")
	attempt = 0
	while attempt < 5 and tag == 0:
		attempt += 1
		logger.info(f"We are now starting the download of {dwnded_file}")
		##### This is where we use requests and not wget
		# with click.progressbar(length = total_size_in_bytes, label = f"Attempting to download file {url}", fill_char='=', empty_char=' ') as bar:
		# 	with open(dwnded_file, 'wb') as file:
		# 		for data in response.iter_content(args["block_size"]):
		# 			bar.update(len(data))
		# 			file.write(data)
		# 	if total_size_in_bytes != 0 and bar.n != total_size_in_bytes:
		# 		logger.info("ERROR, something went wrong -- we try again")
		# 	else:
		# 		real_md5 = md5(dwnded_file)
		# 		logger.debug(f"We expected {expected_md5} and got {real_md5}")
		# 		if expected_md5 != real_md5:
		# 			logger.info("ERROR, the md5 check failed -- we try again")
		# 		else:
		# 			logger.debug(f"{dwnded_file} is all good and has the right md5, we are ok")
		# 			tag = 1
		##### This is where we use wget
		dwnd_cmd = f"wget -O {dwnded_file} {url}"
		p = sp.Popen(dwnd_cmd, shell=True)
		p.wait()
		logger.debug(f"Checking md5sum of {dwnded_file}")
		real_md5 = md5(dwnded_file)
		logger.debug(f"We expected {expected_md5} and got {real_md5}")
		if expected_md5 != real_md5:
			logger.info("ERROR, the md5 check failed -- we try again")
		else:
			logger.debug(f"{dwnded_file} is all good and has the right md5, we are ok")
			tag = 1
	if tag == 0:
		sys.exit(f"Sorry, we tried 5 times to download this file ({url}), and it looks like it failed 5 times. We stop here")
	return dwnded_file

def full_verify(input_dir,logger):
	file_list_file=os.path.join(input_dir,"md5checkfile.txt")
	# Load the list of files and the corresponding md5sums
	with open(file_list_file, "r", newline='') as f:
		file_list = {os.path.normpath(k[2]):k[0] for line in f for k in [line.strip().split(" ")] if not(k[0].startswith("#"))}
	for file_name in file_list:
		file_path = os.path.join(input_dir,file_name)
		if os.path.exists(file_path):
			real_md5 = md5(file_path)
			if file_list[file_name] != real_md5:
				sys.exit(f"We have an issue with {file_name}: {real_md5} while we expected {file_list[file_name]} -- we stop here")
			else:
				logger.info(f"{file_name} ok")
		else:
			sys.exit(f"Pblm -- {file_path} was expected but does not exist, we stop there")
	logger.info(f"All ok, this database in {input_dir} seems all right")

def get_db_name(tar_file):
	dwnd_cmd = f"tar -tf {tar_file} | head -1"
	p = sp.Popen(dwnd_cmd, shell=True, stdout=sp.PIPE)
	p.wait()
	result = p.communicate()[0].decode('utf-8').strip()
	result = os.path.normpath(result)
	return result

def md5(fname):
	hash_md5 = hashlib.md5()
	with open(fname, "rb") as f:
		for chunk in iter(lambda: f.read(4096), b""):
			hash_md5.update(chunk)
	return hash_md5.hexdigest()

## Shamelessly taken from https://gist.github.com/garrettdreyfus/8153571?permalink_comment_id=3543799#gistcomment-3543799
def single_yes_or_no_question(question, auto_response, default_no=True):
	choices = ' [y/N]: ' if default_no else ' [Y/n]: '
	default_answer = 'n' if default_no else 'y'
	if auto_response:
		return True
	else:
		reply = str(input(question + choices)).lower().strip() or default_answer
		if reply[0] == 'y':
			return True
		if reply[0] == 'n':
			return False
		else:
			return False if default_no else True
