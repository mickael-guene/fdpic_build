import sys
import os.path
import subprocess
from optparse import OptionParser

from github import *
from uritemplate import expand

TOKEN=os.environ['GITHUB_TOKEN']

def create_release(owner, repo, tag_name):
    gh = GitHub(access_token=TOKEN)
    gh.repos(owner)(repo).releases.post(tag_name=tag_name, name=tag_name, body=tag_name)


def upload_asset(upload_url, asset_filename):
    cmd = ["curl", "-H", "Authorization: token %s" % TOKEN, "-H", "Accept: application/vnd.github.v3+json",
           "-H", "Content-Type: application/x-compressed", "--data-binary", "@%s" % asset_filename, upload_url]
    subprocess.call(cmd)

def upload_tgz(owner, repo, tag_name, asset_filename):
    gh = GitHub(access_token=TOKEN)
    # get release. create it if it doesn't exist
    try:
        r = gh.repos(owner)(repo).releases.tags(tag_name).get()
    except ApiNotFoundError:
        #print "release %s is not existing. create it" % tag_name
        create_release(owner, repo, tag_name)
        r = gh.repos(owner)(repo).releases.tags(tag_name).get()
    upload_url = expand(r['upload_url'], {"name": os.path.split(asset_filename)[1]})
    upload_asset(upload_url, asset_filename)

def help():
    parser.print_help()
    sys.exit(-1)

if __name__ == "__main__":
    parser = OptionParser(usage="usage: %prog [options] -u <github_user> -r <github_repo> -t <git_tag> <file_name_to_upload>")
    parser.add_option("-u", action="store", type="string", dest="github_user")
    parser.add_option("-r", action="store", type="string", dest="github_repo")
    parser.add_option("-t", action="store", type="string", dest="git_tag")
    (options, args) = parser.parse_args()
    if not options.github_user or not options.github_repo or not options.git_tag or len(args) != 1:
        help()
    #print options.github_user, options.github_repo, options.git_tag, args[0]
    upload_tgz(options.github_user, options.github_repo, options.git_tag, args[0])

