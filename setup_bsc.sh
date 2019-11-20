
# this is latest
export BSPATH=/opt/Bluespec-2017.07.A

export BLUESPECDIR=$BSPATH/lib
export PATH=$BSPATH/bin:$PATH
echo -e "${GREEN}  + Bluespec ${NC}"

GMPLIB="libgmp.so"
GMPLIB3="libgmp.so.3"

# Fix the libgmp.so.3 issue
if [ -z "$(ldconfig -p | grep $GMPLIB3)" ]; then
    # no system-provided libgmp.so.3
    if [ -z "$(ls $HOME/.local/lib | grep $GMPLIB3)" ]; then
        # no user-provided libgmp.so.3
        GMPLIB_PATH=$(ldconfig -p | grep $GMPLIB | head -n 1 | cut -d ">" -f2)
        if [ -n "$GMPLIB_PATH" ]; then
            mkdir -p $HOME/.local/lib && ln -s $GMPLIB_PATH $HOME/.local/lib/$GMPLIB3
        else
            # no libgmp.so in the system at all
            echo -e "${RED}  - libgmp.so Not Found ${NC}"
        fi
    fi
fi

export LM_LICENSE_FILE= #Your license server here
echo -e "${GREEN}  + Bluespec License ${NC}"

